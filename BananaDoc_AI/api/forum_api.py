"""
Forum API endpoints for BananaDoc community forum.
Handles user authentication, posts, comments, and interactions.
"""

import os
import sys
import uuid
from flask import Blueprint, request, jsonify
from functools import wraps

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from utils.firebase_service import FirebaseService
from utils.auth_service import auth_service
from models.forum_user import ForumUser
from models.forum_post import ForumPost
from models.forum_comment import ForumComment

# Create Blueprint for forum routes
forum_bp = Blueprint('forum', __name__, url_prefix='/api/forum')

# Initialize Firebase service
firebase_service = FirebaseService()

# ==================== Helper Functions ====================

def validate_required_fields(data: dict, required_fields: list) -> tuple:
    """
    Validate that all required fields are present in the request data.
    
    Returns:
        (is_valid, error_message)
    """
    missing_fields = [field for field in required_fields if field not in data or not data[field]]
    
    if missing_fields:
        return False, f"Missing required fields: {', '.join(missing_fields)}"
    
    return True, ""


# ==================== Authentication Endpoints ====================

@forum_bp.route('/auth/register', methods=['POST'])
def register():
    """
    Register a new user.
    
    Request body:
        {
            "username": "string",
            "email": "string",
            "password": "string",
            "location": "string (optional)",
            "farmSize": "string (optional)",
            "bio": "string (optional)"
        }
    """
    try:
        data = request.get_json()
        
        # Validate required fields
        is_valid, error_msg = validate_required_fields(data, ['username', 'email', 'password'])
        if not is_valid:
            return jsonify({'success': False, 'error': error_msg}), 400
        
        username = data['username'].strip()
        email = data['email'].strip().lower()
        password = data['password']
        
        # Validate username and email length
        if len(username) < 3:
            return jsonify({'success': False, 'error': 'Username must be at least 3 characters'}), 400
        
        if len(password) < 6:
            return jsonify({'success': False, 'error': 'Password must be at least 6 characters'}), 400
        
        # Check if username already exists
        existing_user = firebase_service.get_user_by_username(username)
        if existing_user:
            return jsonify({'success': False, 'error': 'Username already exists'}), 409
        
        # Check if email already exists
        existing_email = firebase_service.get_user_by_email(email)
        if existing_email:
            return jsonify({'success': False, 'error': 'Email already registered'}), 409
        
        # Hash password
        hashed_password = auth_service.hash_password(password)
        
        # Create user
        user_id = str(uuid.uuid4())
        user = ForumUser(
            user_id=user_id,
            username=username,
            email=email,
            location=data.get('location', ''),
            farm_size=data.get('farmSize', ''),
            bio=data.get('bio', ''),
            role='farmer'
        )
        
        # Save to Firestore
        user_data = user.to_dict()
        user_data['password'] = hashed_password  # Store hashed password
        
        created_id = firebase_service.create_user(user_data)
        
        if not created_id:
            return jsonify({'success': False, 'error': 'Failed to create user'}), 500
        
        # Generate JWT token
        token = auth_service.generate_token(user_id, username, user.role)
        
        # Return user info without password
        user_response = user.to_dict()
        
        return jsonify({
            'success': True,
            'message': 'User registered successfully',
            'token': token,
            'user': user_response
        }), 201
        
    except Exception as e:
        print(f"Error in register: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/auth/login', methods=['POST'])
def login():
    """
    Login a user.
    
    Request body:
        {
            "username": "string",  # or email
            "password": "string"
        }
    """
    try:
        data = request.get_json()
        
        # Validate required fields
        is_valid, error_msg = validate_required_fields(data, ['username', 'password'])
        if not is_valid:
            return jsonify({'success': False, 'error': error_msg}), 400
        
        username_or_email = data['username'].strip().lower()
        password = data['password']
        
        # Try to find user by username or email
        user_data = firebase_service.get_user_by_username(username_or_email)
        if not user_data:
            user_data = firebase_service.get_user_by_email(username_or_email)
        
        if not user_data:
            return jsonify({'success': False, 'error': 'Invalid username or password'}), 401
        
        # Verify password
        stored_password = user_data.get('password', '')
        if not auth_service.verify_password(password, stored_password):
            return jsonify({'success': False, 'error': 'Invalid username or password'}), 401
        
        # Generate JWT token
        token = auth_service.generate_token(
            user_data['userId'],
            user_data['username'],
            user_data.get('role', 'farmer')
        )
        
        # Remove password from response
        user_data.pop('password', None)
        
        return jsonify({
            'success': True,
            'message': 'Login successful',
            'token': token,
            'user': user_data
        }), 200
        
    except Exception as e:
        print(f"Error in login: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


# ==================== User Endpoints ====================

@forum_bp.route('/users/<user_id>', methods=['GET'])
@auth_service.optional_auth
def get_user(current_user, user_id):
    """Get user profile by ID."""
    try:
        user_data = firebase_service.get_user(user_id)
        
        if not user_data:
            return jsonify({'success': False, 'error': 'User not found'}), 404
        
        # Remove password from response
        user_data.pop('password', None)
        
        return jsonify({
            'success': True,
            'user': user_data
        }), 200
        
    except Exception as e:
        print(f"Error in get_user: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/users/<user_id>', methods=['PUT'])
@auth_service.require_auth
def update_user(current_user, user_id):
    """Update user profile."""
    try:
        # Check if user is updating their own profile or is admin
        if current_user['user_id'] != user_id and current_user.get('role') != 'admin':
            return jsonify({'success': False, 'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Fields that can be updated
        allowed_fields = ['username', 'location', 'farmSize', 'bio', 'profilePicture']
        update_data = {k: v for k, v in data.items() if k in allowed_fields}
        
        if not update_data:
            return jsonify({'success': False, 'error': 'No valid fields to update'}), 400
        
        # If updating username, check if it's already taken
        if 'username' in update_data:
            existing = firebase_service.get_user_by_username(update_data['username'])
            if existing and existing.get('userId') != user_id:
                return jsonify({'success': False, 'error': 'Username already taken'}), 409
        
        success = firebase_service.update_user(user_id, update_data)
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to update user'}), 500
        
        # Get updated user data
        updated_user = firebase_service.get_user(user_id)
        updated_user.pop('password', None)
        
        return jsonify({
            'success': True,
            'message': 'User updated successfully',
            'user': updated_user
        }), 200
        
    except Exception as e:
        print(f"Error in update_user: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


# ==================== Post Endpoints ====================

@forum_bp.route('/posts', methods=['GET'])
@auth_service.optional_auth
def get_posts(current_user):
    """
    Get posts with optional filtering and pagination.
    
    Query parameters:
        - limit: int (default: 20, max: 100)
        - offset: int (default: 0)
        - category: string (question, discussion, tip, problem)
        - authorId: string (filter by author)
        - deficiencyType: string (filter by deficiency type)
    """
    try:
        limit = min(int(request.args.get('limit', 20)), 100)
        offset = int(request.args.get('offset', 0))
        category = request.args.get('category')
        author_id = request.args.get('authorId')
        deficiency_type = request.args.get('deficiencyType')
        
        posts = firebase_service.get_posts(
            limit=limit,
            offset=offset,
            category=category,
            author_id=author_id,
            deficiency_type=deficiency_type
        )
        
        return jsonify({
            'success': True,
            'posts': posts,
            'count': len(posts)
        }), 200
        
    except Exception as e:
        print(f"Error in get_posts: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/posts', methods=['POST'])
@auth_service.require_auth
def create_post(current_user):
    """
    Create a new post.
    
    Request body:
        {
            "title": "string",
            "content": "string",
            "category": "string",
            "images": ["url1", "url2"] (optional),
            "deficiencyType": "string" (optional),
            "tags": ["tag1", "tag2"] (optional),
            "location": "string" (optional)
        }
    """
    try:
        data = request.get_json()
        
        # Validate required fields
        is_valid, error_msg = validate_required_fields(data, ['title', 'content', 'category'])
        if not is_valid:
            return jsonify({'success': False, 'error': error_msg}), 400
        
        # Validate category
        if data['category'] not in ForumPost.VALID_CATEGORIES:
            return jsonify({
                'success': False,
                'error': f"Invalid category. Must be one of: {', '.join(ForumPost.VALID_CATEGORIES)}"
            }), 400
        
        # Create post
        post_id = str(uuid.uuid4())
        post = ForumPost(
            post_id=post_id,
            author_id=current_user['user_id'],
            title=data['title'],
            content=data['content'],
            category=data['category'],
            images=data.get('images', []),
            deficiency_type=data.get('deficiencyType'),
            tags=data.get('tags', []),
            location=data.get('location', '')
        )
        
        # Save to Firestore
        created_id = firebase_service.create_post(post.to_dict())
        
        if not created_id:
            return jsonify({'success': False, 'error': 'Failed to create post'}), 500
        
        return jsonify({
            'success': True,
            'message': 'Post created successfully',
            'post': post.to_dict()
        }), 201
        
    except Exception as e:
        print(f"Error in create_post: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/posts/<post_id>', methods=['GET'])
@auth_service.optional_auth
def get_post(current_user, post_id):
    """Get a single post by ID."""
    try:
        post_data = firebase_service.get_post(post_id)
        
        if not post_data:
            return jsonify({'success': False, 'error': 'Post not found'}), 404
        
        # Increment view count
        firebase_service.increment_post_views(post_id)
        
        return jsonify({
            'success': True,
            'post': post_data
        }), 200
        
    except Exception as e:
        print(f"Error in get_post: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/posts/<post_id>', methods=['PUT'])
@auth_service.require_auth
def update_post(current_user, post_id):
    """Update a post."""
    try:
        # Get existing post
        post_data = firebase_service.get_post(post_id)
        
        if not post_data:
            return jsonify({'success': False, 'error': 'Post not found'}), 404
        
        # Check if user is the author or admin
        if post_data['authorId'] != current_user['user_id'] and current_user.get('role') != 'admin':
            return jsonify({'success': False, 'error': 'Unauthorized'}), 403
        
        data = request.get_json()
        
        # Fields that can be updated
        allowed_fields = ['title', 'content', 'category', 'images', 'tags', 'deficiencyType', 'location']
        update_data = {k: v for k, v in data.items() if k in allowed_fields}
        
        if not update_data:
            return jsonify({'success': False, 'error': 'No valid fields to update'}), 400
        
        # Validate category if being updated
        if 'category' in update_data and update_data['category'] not in ForumPost.VALID_CATEGORIES:
            return jsonify({'success': False, 'error': 'Invalid category'}), 400
        
        success = firebase_service.update_post(post_id, update_data)
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to update post'}), 500
        
        # Get updated post
        updated_post = firebase_service.get_post(post_id)
        
        return jsonify({
            'success': True,
            'message': 'Post updated successfully',
            'post': updated_post
        }), 200
        
    except Exception as e:
        print(f"Error in update_post: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/posts/<post_id>', methods=['DELETE'])
@auth_service.require_auth
def delete_post(current_user, post_id):
    """Delete a post."""
    try:
        # Get existing post
        post_data = firebase_service.get_post(post_id)
        
        if not post_data:
            return jsonify({'success': False, 'error': 'Post not found'}), 404
        
        # Check if user is the author or admin
        if post_data['authorId'] != current_user['user_id'] and current_user.get('role') != 'admin':
            return jsonify({'success': False, 'error': 'Unauthorized'}), 403
        
        success = firebase_service.delete_post(post_id)
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to delete post'}), 500
        
        return jsonify({
            'success': True,
            'message': 'Post deleted successfully'
        }), 200
        
    except Exception as e:
        print(f"Error in delete_post: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/posts/<post_id>/solve', methods=['POST'])
@auth_service.require_auth
def mark_post_solved(current_user, post_id):
    """Mark a post as solved."""
    try:
        # Get existing post
        post_data = firebase_service.get_post(post_id)
        
        if not post_data:
            return jsonify({'success': False, 'error': 'Post not found'}), 404
        
        # Check if user is the author or admin
        if post_data['authorId'] != current_user['user_id'] and current_user.get('role') != 'admin':
            return jsonify({'success': False, 'error': 'Unauthorized'}), 403
        
        success = firebase_service.update_post(post_id, {'isSolved': True})
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to mark post as solved'}), 500
        
        return jsonify({
            'success': True,
            'message': 'Post marked as solved'
        }), 200
        
    except Exception as e:
        print(f"Error in mark_post_solved: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


# ==================== Comment Endpoints ====================

@forum_bp.route('/posts/<post_id>/comments', methods=['GET'])
@auth_service.optional_auth
def get_comments(current_user, post_id):
    """Get all comments for a post."""
    try:
        comments = firebase_service.get_comments_by_post(post_id)
        
        return jsonify({
            'success': True,
            'comments': comments,
            'count': len(comments)
        }), 200
        
    except Exception as e:
        print(f"Error in get_comments: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/posts/<post_id>/comments', methods=['POST'])
@auth_service.require_auth
def create_comment(current_user, post_id):
    """
    Create a new comment on a post.
    
    Request body:
        {
            "content": "string",
            "images": ["url1", "url2"] (optional)
        }
    """
    try:
        # Verify post exists
        post_data = firebase_service.get_post(post_id)
        if not post_data:
            return jsonify({'success': False, 'error': 'Post not found'}), 404
        
        data = request.get_json()
        
        # Validate required fields
        is_valid, error_msg = validate_required_fields(data, ['content'])
        if not is_valid:
            return jsonify({'success': False, 'error': error_msg}), 400
        
        # Create comment
        comment_id = str(uuid.uuid4())
        comment = ForumComment(
            comment_id=comment_id,
            post_id=post_id,
            author_id=current_user['user_id'],
            content=data['content'],
            images=data.get('images', [])
        )
        
        # Save to Firestore
        created_id = firebase_service.create_comment(comment.to_dict())
        
        if not created_id:
            return jsonify({'success': False, 'error': 'Failed to create comment'}), 500
        
        return jsonify({
            'success': True,
            'message': 'Comment created successfully',
            'comment': comment.to_dict()
        }), 201
        
    except Exception as e:
        print(f"Error in create_comment: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/comments/<comment_id>', methods=['PUT'])
@auth_service.require_auth
def update_comment(current_user, comment_id):
    """Update a comment."""
    try:
        data = request.get_json()
        
        # Only content and images can be updated
        update_data = {}
        if 'content' in data:
            update_data['content'] = data['content']
        if 'images' in data:
            update_data['images'] = data['images']
        
        if not update_data:
            return jsonify({'success': False, 'error': 'No valid fields to update'}), 400
        
        success = firebase_service.update_comment(comment_id, update_data)
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to update comment'}), 500
        
        return jsonify({
            'success': True,
            'message': 'Comment updated successfully'
        }), 200
        
    except Exception as e:
        print(f"Error in update_comment: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/comments/<comment_id>', methods=['DELETE'])
@auth_service.require_auth
def delete_comment(current_user, comment_id):
    """Delete a comment."""
    try:
        data = request.get_json()
        post_id = data.get('postId')
        
        if not post_id:
            return jsonify({'success': False, 'error': 'postId is required'}), 400
        
        success = firebase_service.delete_comment(comment_id, post_id)
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to delete comment'}), 500
        
        return jsonify({
            'success': True,
            'message': 'Comment deleted successfully'
        }), 200
        
    except Exception as e:
        print(f"Error in delete_comment: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


# ==================== Like Endpoints ====================

@forum_bp.route('/posts/<post_id>/like', methods=['POST'])
@auth_service.require_auth
def like_post(current_user, post_id):
    """Like or unlike a post."""
    try:
        user_id = current_user['user_id']
        
        # Check if already liked
        has_liked = firebase_service.user_has_liked(user_id, post_id)
        
        if has_liked:
            # Unlike
            success = firebase_service.remove_like(user_id, post_id, 'post')
            message = 'Post unliked'
        else:
            # Like
            success = firebase_service.add_like(user_id, post_id, 'post')
            message = 'Post liked'
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to toggle like'}), 500
        
        return jsonify({
            'success': True,
            'message': message,
            'liked': not has_liked
        }), 200
        
    except Exception as e:
        print(f"Error in like_post: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


@forum_bp.route('/comments/<comment_id>/like', methods=['POST'])
@auth_service.require_auth
def like_comment(current_user, comment_id):
    """Like or unlike a comment."""
    try:
        user_id = current_user['user_id']
        
        # Check if already liked
        has_liked = firebase_service.user_has_liked(user_id, comment_id)
        
        if has_liked:
            # Unlike
            success = firebase_service.remove_like(user_id, comment_id, 'comment')
            message = 'Comment unliked'
        else:
            # Like
            success = firebase_service.add_like(user_id, comment_id, 'comment')
            message = 'Comment liked'
        
        if not success:
            return jsonify({'success': False, 'error': 'Failed to toggle like'}), 500
        
        return jsonify({
            'success': True,
            'message': message,
            'liked': not has_liked
        }), 200
        
    except Exception as e:
        print(f"Error in like_comment: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


# ==================== Search Endpoint ====================

@forum_bp.route('/search', methods=['GET'])
@auth_service.optional_auth
def search_posts(current_user):
    """
    Search posts by title or content.
    
    Query parameters:
        - q: search query
        - limit: max results (default: 20)
    """
    try:
        query = request.args.get('q', '')
        limit = min(int(request.args.get('limit', 20)), 100)
        
        if not query:
            return jsonify({'success': False, 'error': 'Search query is required'}), 400
        
        posts = firebase_service.search_posts(query, limit)
        
        return jsonify({
            'success': True,
            'posts': posts,
            'count': len(posts)
        }), 200
        
    except Exception as e:
        print(f"Error in search_posts: {e}")
        return jsonify({'success': False, 'error': 'Internal server error'}), 500


# Export the blueprint
__all__ = ['forum_bp']
