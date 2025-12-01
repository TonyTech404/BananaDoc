"""
Forum Comment model for BananaDoc community forum.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any


class ForumComment:
    """Represents a comment on a forum post."""
    
    def __init__(
        self,
        comment_id: str,
        post_id: str,
        author_id: str,
        content: str,
        images: Optional[List[str]] = None,
        likes: int = 0,
        is_marked_as_answer: bool = False,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None
    ):
        self.comment_id = comment_id
        self.post_id = post_id
        self.author_id = author_id
        self.content = content
        self.images = images or []
        self.likes = likes
        self.is_marked_as_answer = is_marked_as_answer
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert comment object to dictionary for Firestore."""
        return {
            'commentId': self.comment_id,
            'postId': self.post_id,
            'authorId': self.author_id,
            'content': self.content,
            'images': self.images,
            'likes': self.likes,
            'isMarkedAsAnswer': self.is_marked_as_answer,
            'createdAt': self.created_at,
            'updatedAt': self.updated_at
        }
    
    @staticmethod
    def from_dict(data: Dict[str, Any]) -> 'ForumComment':
        """Create ForumComment object from Firestore document."""
        return ForumComment(
            comment_id=data.get('commentId', ''),
            post_id=data.get('postId', ''),
            author_id=data.get('authorId', ''),
            content=data.get('content', ''),
            images=data.get('images', []),
            likes=data.get('likes', 0),
            is_marked_as_answer=data.get('isMarkedAsAnswer', False),
            created_at=data.get('createdAt'),
            updated_at=data.get('updatedAt')
        )
    
    def increment_likes(self):
        """Increment comment like count."""
        self.likes += 1
        self.updated_at = datetime.utcnow()
    
    def decrement_likes(self):
        """Decrement comment like count."""
        self.likes = max(0, self.likes - 1)
        self.updated_at = datetime.utcnow()
    
    def mark_as_answer(self):
        """Mark this comment as the accepted answer."""
        self.is_marked_as_answer = True
        self.updated_at = datetime.utcnow()
    
    def unmark_as_answer(self):
        """Unmark this comment as the accepted answer."""
        self.is_marked_as_answer = False
        self.updated_at = datetime.utcnow()
    
    def __repr__(self):
        return f"<ForumComment on post {self.post_id} by {self.author_id}>"
