"""
Firebase service for BananaDoc forum.
Handles all Firebase Admin SDK operations for Firestore and Storage.
"""

import os
import firebase_admin
from firebase_admin import credentials, firestore, storage
from typing import Optional, Dict, Any, List
from datetime import datetime


class FirebaseService:
    """Service for interacting with Firebase Firestore and Storage."""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        """Singleton pattern to ensure only one Firebase instance."""
        if cls._instance is None:
            cls._instance = super(FirebaseService, cls).__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize Firebase Admin SDK."""
        if not FirebaseService._initialized:
            self._initialize_firebase()
            FirebaseService._initialized = True
    
    def _initialize_firebase(self):
        """Initialize Firebase with service account credentials."""
        try:
            # Get Firebase config path from environment
            config_path = os.environ.get('FIREBASE_CONFIG_PATH', './firebase_config.json')
            
            # Make path absolute if it's relative
            if not os.path.isabs(config_path):
                base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                config_path = os.path.join(base_dir, config_path)
            
            # Check if config file exists
            if not os.path.exists(config_path):
                print(f"WARNING: Firebase config not found at {config_path}")
                print("Please create firebase_config.json with your Firebase credentials.")
                print("See firebase_config_example.json for the required format.")
                self.db = None
                self.bucket = None
                return
            
            # Initialize Firebase Admin SDK
            cred = credentials.Certificate(config_path)
            firebase_admin.initialize_app(cred, {
                'storageBucket': os.environ.get('FIREBASE_STORAGE_BUCKET', None)
            })
            
            # Get Firestore client
            self.db = firestore.client()
            
            # Get Storage bucket
            try:
                self.bucket = storage.bucket()
                print("✓ Firebase initialized successfully!")
            except Exception as e:
                print(f"Warning: Firebase Storage not configured: {e}")
                self.bucket = None
                print("✓ Firebase Firestore initialized successfully!")
            
        except Exception as e:
            print(f"Error initializing Firebase: {e}")
            self.db = None
            self.bucket = None
    
    def is_initialized(self) -> bool:
        """Check if Firebase is properly initialized."""
        return self.db is not None
    
    # ==================== User Operations ====================
    
    def create_user(self, user_data: Dict[str, Any]) -> Optional[str]:
        """
        Create a new user in Firestore.
        
        Args:
            user_data: Dictionary containing user information
            
        Returns:
            User ID if successful, None otherwise
        """
        if not self.is_initialized():
            return None
        
        try:
            user_data['createdAt'] = datetime.utcnow()
            user_data['updatedAt'] = datetime.utcnow()
            
            # Auto-generate ID or use provided userId
            if 'userId' in user_data:
                user_id = user_data['userId']
                self.db.collection('users').document(user_id).set(user_data)
            else:
                doc_ref = self.db.collection('users').add(user_data)[1]
                user_id = doc_ref.id
                self.db.collection('users').document(user_id).update({'userId': user_id})
            
            return user_id
        except Exception as e:
            print(f"Error creating user: {e}")
            return None
    
    def get_user(self, user_id: str) -> Optional[Dict[str, Any]]:
        """Get user by ID."""
        if not self.is_initialized():
            return None
        
        try:
            doc = self.db.collection('users').document(user_id).get()
            return doc.to_dict() if doc.exists else None
        except Exception as e:
            print(f"Error getting user: {e}")
            return None
    
    def get_user_by_email(self, email: str) -> Optional[Dict[str, Any]]:
        """Get user by email."""
        if not self.is_initialized():
            return None
        
        try:
            users = self.db.collection('users').where('email', '==', email).limit(1).stream()
            for user in users:
                return user.to_dict()
            return None
        except Exception as e:
            print(f"Error getting user by email: {e}")
            return None
    
    def get_user_by_username(self, username: str) -> Optional[Dict[str, Any]]:
        """Get user by username."""
        if not self.is_initialized():
            return None
        
        try:
            users = self.db.collection('users').where('username', '==', username).limit(1).stream()
            for user in users:
                return user.to_dict()
            return None
        except Exception as e:
            print(f"Error getting user by username: {e}")
            return None
    
    def update_user(self, user_id: str, user_data: Dict[str, Any]) -> bool:
        """Update user information."""
        if not self.is_initialized():
            return False
        
        try:
            user_data['updatedAt'] = datetime.utcnow()
            self.db.collection('users').document(user_id).update(user_data)
            return True
        except Exception as e:
            print(f"Error updating user: {e}")
            return False
    
    # ==================== Post Operations ====================
    
    def create_post(self, post_data: Dict[str, Any]) -> Optional[str]:
        """Create a new post."""
        if not self.is_initialized():
            return None
        
        try:
            post_data['createdAt'] = datetime.utcnow()
            post_data['updatedAt'] = datetime.utcnow()
            
            if 'postId' in post_data:
                post_id = post_data['postId']
                self.db.collection('posts').document(post_id).set(post_data)
            else:
                doc_ref = self.db.collection('posts').add(post_data)[1]
                post_id = doc_ref.id
                self.db.collection('posts').document(post_id).update({'postId': post_id})
            
            return post_id
        except Exception as e:
            print(f"Error creating post: {e}")
            return None
    
    def get_post(self, post_id: str) -> Optional[Dict[str, Any]]:
        """Get post by ID."""
        if not self.is_initialized():
            return None
        
        try:
            doc = self.db.collection('posts').document(post_id).get()
            return doc.to_dict() if doc.exists else None
        except Exception as e:
            print(f"Error getting post: {e}")
            return None
    
    def get_posts(
        self,
        limit: int = 20,
        offset: int = 0,
        category: Optional[str] = None,
        author_id: Optional[str] = None,
        deficiency_type: Optional[str] = None,
        order_by: str = 'createdAt',
        descending: bool = True
    ) -> List[Dict[str, Any]]:
        """
        Get posts with optional filtering and pagination.
        
        Args:
            limit: Maximum number of posts to return
            offset: Number of posts to skip
            category: Filter by category
            author_id: Filter by author
            deficiency_type: Filter by deficiency type
            order_by: Field to order by
            descending: Order direction
        """
        if not self.is_initialized():
            return []
        
        try:
            query = self.db.collection('posts')
            
            # Apply filters
            if category:
                query = query.where('category', '==', category)
            if author_id:
                query = query.where('authorId', '==', author_id)
            if deficiency_type:
                query = query.where('deficiencyType', '==', deficiency_type)
            
            # Order and paginate
            direction = firestore.Query.DESCENDING if descending else firestore.Query.ASCENDING
            query = query.order_by(order_by, direction=direction).limit(limit).offset(offset)
            
            posts = []
            for doc in query.stream():
                posts.append(doc.to_dict())
            
            return posts
        except Exception as e:
            print(f"Error getting posts: {e}")
            return []
    
    def update_post(self, post_id: str, post_data: Dict[str, Any]) -> bool:
        """Update post information."""
        if not self.is_initialized():
            return False
        
        try:
            post_data['updatedAt'] = datetime.utcnow()
            self.db.collection('posts').document(post_id).update(post_data)
            return True
        except Exception as e:
            print(f"Error updating post: {e}")
            return False
    
    def delete_post(self, post_id: str) -> bool:
        """Delete a post."""
        if not self.is_initialized():
            return False
        
        try:
            self.db.collection('posts').document(post_id).delete()
            return True
        except Exception as e:
            print(f"Error deleting post: {e}")
            return False
    
    def increment_post_views(self, post_id: str) -> bool:
        """Increment post view count."""
        if not self.is_initialized():
            return False
        
        try:
            post_ref = self.db.collection('posts').document(post_id)
            post_ref.update({
                'views': firestore.Increment(1)
            })
            return True
        except Exception as e:
            print(f"Error incrementing post views: {e}")
            return False
    
    # ==================== Comment Operations ====================
    
    def create_comment(self, comment_data: Dict[str, Any]) -> Optional[str]:
        """Create a new comment."""
        if not self.is_initialized():
            return None
        
        try:
            comment_data['createdAt'] = datetime.utcnow()
            comment_data['updatedAt'] = datetime.utcnow()
            
            if 'commentId' in comment_data:
                comment_id = comment_data['commentId']
                self.db.collection('comments').document(comment_id).set(comment_data)
            else:
                doc_ref = self.db.collection('comments').add(comment_data)[1]
                comment_id = doc_ref.id
                self.db.collection('comments').document(comment_id).update({'commentId': comment_id})
            
            # Increment post comment count
            post_id = comment_data.get('postId')
            if post_id:
                self.db.collection('posts').document(post_id).update({
                    'commentCount': firestore.Increment(1)
                })
            
            return comment_id
        except Exception as e:
            print(f"Error creating comment: {e}")
            return None
    
    def get_comments_by_post(self, post_id: str, limit: int = 50) -> List[Dict[str, Any]]:
        """Get all comments for a post."""
        if not self.is_initialized():
            return []
        
        try:
            query = self.db.collection('comments').where('postId', '==', post_id)\
                .order_by('createdAt', direction=firestore.Query.ASCENDING)\
                .limit(limit)
            
            comments = []
            for doc in query.stream():
                comments.append(doc.to_dict())
            
            return comments
        except Exception as e:
            print(f"Error getting comments: {e}")
            return []
    
    def update_comment(self, comment_id: str, comment_data: Dict[str, Any]) -> bool:
        """Update comment information."""
        if not self.is_initialized():
            return False
        
        try:
            comment_data['updatedAt'] = datetime.utcnow()
            self.db.collection('comments').document(comment_id).update(comment_data)
            return True
        except Exception as e:
            print(f"Error updating comment: {e}")
            return False
    
    def delete_comment(self, comment_id: str, post_id: str) -> bool:
        """Delete a comment."""
        if not self.is_initialized():
            return False
        
        try:
            self.db.collection('comments').document(comment_id).delete()
            
            # Decrement post comment count
            self.db.collection('posts').document(post_id).update({
                'commentCount': firestore.Increment(-1)
            })
            
            return True
        except Exception as e:
            print(f"Error deleting comment: {e}")
            return False
    
    # ==================== Like Operations ====================
    
    def add_like(self, user_id: str, target_id: str, target_type: str) -> Optional[str]:
        """Add a like to a post or comment."""
        if not self.is_initialized():
            return None
        
        try:
            like_data = {
                'userId': user_id,
                'targetId': target_id,
                'targetType': target_type,  # 'post' or 'comment'
                'createdAt': datetime.utcnow()
            }
            
            # Check if like already exists
            existing = self.db.collection('likes')\
                .where('userId', '==', user_id)\
                .where('targetId', '==', target_id)\
                .limit(1).stream()
            
            for doc in existing:
                return doc.id  # Already liked
            
            # Create new like
            doc_ref = self.db.collection('likes').add(like_data)[1]
            
            # Increment like count on target
            collection = 'posts' if target_type == 'post' else 'comments'
            self.db.collection(collection).document(target_id).update({
                'likes': firestore.Increment(1)
            })
            
            return doc_ref.id
        except Exception as e:
            print(f"Error adding like: {e}")
            return None
    
    def remove_like(self, user_id: str, target_id: str, target_type: str) -> bool:
        """Remove a like from a post or comment."""
        if not self.is_initialized():
            return False
        
        try:
            # Find and delete the like
            likes = self.db.collection('likes')\
                .where('userId', '==', user_id)\
                .where('targetId', '==', target_id)\
                .limit(1).stream()
            
            deleted = False
            for like in likes:
                self.db.collection('likes').document(like.id).delete()
                deleted = True
            
            if deleted:
                # Decrement like count on target
                collection = 'posts' if target_type == 'post' else 'comments'
                self.db.collection(collection).document(target_id).update({
                    'likes': firestore.Increment(-1)
                })
            
            return deleted
        except Exception as e:
            print(f"Error removing like: {e}")
            return False
    
    def user_has_liked(self, user_id: str, target_id: str) -> bool:
        """Check if user has liked a post or comment."""
        if not self.is_initialized():
            return False
        
        try:
            likes = self.db.collection('likes')\
                .where('userId', '==', user_id)\
                .where('targetId', '==', target_id)\
                .limit(1).stream()
            
            for _ in likes:
                return True
            return False
        except Exception as e:
            print(f"Error checking like: {e}")
            return False
    
    # ==================== Search Operations ====================
    
    def search_posts(self, query: str, limit: int = 20) -> List[Dict[str, Any]]:
        """
        Search posts by title or content.
        Note: This is a basic implementation. For production,
        consider using Algolia or Elasticsearch for better search.
        """
        if not self.is_initialized():
            return []
        
        try:
            # Simple search by title (Firestore has limited text search)
            posts = []
            query_lower = query.lower()
            
            # Get all posts (in production, use proper search service)
            all_posts = self.db.collection('posts').stream()
            
            for doc in all_posts:
                post_data = doc.to_dict()
                title = post_data.get('title', '').lower()
                content = post_data.get('content', '').lower()
                
                if query_lower in title or query_lower in content:
                    posts.append(post_data)
                    
                if len(posts) >= limit:
                    break
            
            return posts
        except Exception as e:
            print(f"Error searching posts: {e}")
            return []
