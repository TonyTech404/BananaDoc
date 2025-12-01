"""
Authentication utilities for BananaDoc forum.
Handles JWT token generation and validation, password hashing.
"""

import os
import jwt
import bcrypt
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from functools import wraps
from flask import request, jsonify


class AuthService:
    """Service for handling user authentication."""
    
    def __init__(self):
        """Initialize authentication service."""
        self.secret_key = os.environ.get('JWT_SECRET_KEY', 'your-secret-key-change-in-production')
        self.expiration_hours = int(os.environ.get('JWT_EXPIRATION_HOURS', 24))
        
        if self.secret_key == 'your-secret-key-change-in-production':
            print("WARNING: Using default JWT secret key. Set JWT_SECRET_KEY in .env for production!")
    
    def hash_password(self, password: str) -> str:
        """
        Hash a password using bcrypt.
        
        Args:
            password: Plain text password
            
        Returns:
            Hashed password
        """
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')
    
    def verify_password(self, password: str, hashed_password: str) -> bool:
        """
        Verify a password against a hash.
        
        Args:
            password: Plain text password
            hashed_password: Hashed password to compare against
            
        Returns:
            True if password matches, False otherwise
        """
        try:
            return bcrypt.checkpw(password.encode('utf-8'), hashed_password.encode('utf-8'))
        except Exception as e:
            print(f"Error verifying password: {e}")
            return False
    
    def generate_token(self, user_id: str, username: str, role: str = 'farmer') -> str:
        """
        Generate a JWT token for a user.
        
        Args:
            user_id: User's unique ID
            username: User's username
            role: User's role (farmer, expert, admin)
            
        Returns:
            JWT token string
        """
        try:
            payload = {
                'user_id': user_id,
                'username': username,
                'role': role,
                'exp': datetime.utcnow() + timedelta(hours=self.expiration_hours),
                'iat': datetime.utcnow()
            }
            
            token = jwt.encode(payload, self.secret_key, algorithm='HS256')
            return token
        except Exception as e:
            print(f"Error generating token: {e}")
            return ''
    
    def decode_token(self, token: str) -> Optional[Dict[str, Any]]:
        """
        Decode and validate a JWT token.
        
        Args:
            token: JWT token string
            
        Returns:
            Decoded payload if valid, None otherwise
        """
        try:
            payload = jwt.decode(token, self.secret_key, algorithms=['HS256'])
            return payload
        except jwt.ExpiredSignatureError:
            print("Token has expired")
            return None
        except jwt.InvalidTokenError as e:
            print(f"Invalid token: {e}")
            return None
    
    def get_token_from_request(self) -> Optional[str]:
        """
        Extract JWT token from request headers.
        Looks for 'Authorization: Bearer <token>' header.
        
        Returns:
            Token string if found, None otherwise
        """
        auth_header = request.headers.get('Authorization')
        
        if not auth_header:
            return None
        
        # Expected format: "Bearer <token>"
        parts = auth_header.split()
        
        if len(parts) != 2 or parts[0].lower() != 'bearer':
            return None
        
        return parts[1]
    
    def require_auth(self, f):
        """
        Decorator to require authentication for a route.
        
        Usage:
            @app.route('/protected')
            @auth_service.require_auth
            def protected_route(current_user):
                return jsonify({'user': current_user})
        """
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = self.get_token_from_request()
            
            if not token:
                return jsonify({
                    'success': False,
                    'error': 'Authentication required. Please provide a valid token.'
                }), 401
            
            payload = self.decode_token(token)
            
            if not payload:
                return jsonify({
                    'success': False,
                    'error': 'Invalid or expired token. Please login again.'
                }), 401
            
            # Pass the user info to the route
            return f(current_user=payload, *args, **kwargs)
        
        return decorated_function
    
    def require_role(self, required_role: str):
        """
        Decorator to require a specific role for a route.
        
        Args:
            required_role: Required user role (e.g., 'admin', 'expert')
        
        Usage:
            @app.route('/admin')
            @auth_service.require_role('admin')
            def admin_route(current_user):
                return jsonify({'message': 'Admin access'})
        """
        def decorator(f):
            @wraps(f)
            def decorated_function(*args, **kwargs):
                token = self.get_token_from_request()
                
                if not token:
                    return jsonify({
                        'success': False,
                        'error': 'Authentication required.'
                    }), 401
                
                payload = self.decode_token(token)
                
                if not payload:
                    return jsonify({
                        'success': False,
                        'error': 'Invalid or expired token.'
                    }), 401
                
                user_role = payload.get('role', 'farmer')
                
                # Admin has access to everything
                if user_role == 'admin':
                    return f(current_user=payload, *args, **kwargs)
                
                # Check if user has required role
                if user_role != required_role:
                    return jsonify({
                        'success': False,
                        'error': f'Access denied. {required_role} role required.'
                    }), 403
                
                return f(current_user=payload, *args, **kwargs)
            
            return decorated_function
        return decorator
    
    def optional_auth(self, f):
        """
        Decorator for routes where authentication is optional.
        If token is provided and valid, user info is passed.
        If no token or invalid token, current_user will be None.
        
        Usage:
            @app.route('/posts')
            @auth_service.optional_auth
            def get_posts(current_user):
                # current_user is None if not authenticated
                return jsonify({'posts': posts})
        """
        @wraps(f)
        def decorated_function(*args, **kwargs):
            token = self.get_token_from_request()
            current_user = None
            
            if token:
                payload = self.decode_token(token)
                if payload:
                    current_user = payload
            
            return f(current_user=current_user, *args, **kwargs)
        
        return decorated_function


# Create a global instance
auth_service = AuthService()
