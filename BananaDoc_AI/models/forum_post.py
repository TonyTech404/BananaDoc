"""
Forum Post model for BananaDoc community forum.
"""

from datetime import datetime
from typing import Optional, List, Dict, Any


class ForumPost:
    """Represents a post in the farmer community forum."""
    
    # Post categories
    CATEGORY_QUESTION = "question"
    CATEGORY_DISCUSSION = "discussion"
    CATEGORY_TIP = "tip"
    CATEGORY_PROBLEM = "problem"
    
    VALID_CATEGORIES = [CATEGORY_QUESTION, CATEGORY_DISCUSSION, CATEGORY_TIP, CATEGORY_PROBLEM]
    
    def __init__(
        self,
        post_id: str,
        author_id: str,
        title: str,
        content: str,
        category: str = CATEGORY_QUESTION,
        images: Optional[List[str]] = None,
        deficiency_type: Optional[str] = None,
        tags: Optional[List[str]] = None,
        location: Optional[str] = None,
        likes: int = 0,
        views: int = 0,
        comment_count: int = 0,
        is_pinned: bool = False,
        is_solved: bool = False,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None
    ):
        self.post_id = post_id
        self.author_id = author_id
        self.title = title
        self.content = content
        self.category = category if category in self.VALID_CATEGORIES else self.CATEGORY_QUESTION
        self.images = images or []
        self.deficiency_type = deficiency_type
        self.tags = tags or []
        self.location = location or ""
        self.likes = likes
        self.views = views
        self.comment_count = comment_count
        self.is_pinned = is_pinned
        self.is_solved = is_solved
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert post object to dictionary for Firestore."""
        return {
            'postId': self.post_id,
            'authorId': self.author_id,
            'title': self.title,
            'content': self.content,
            'category': self.category,
            'images': self.images,
            'deficiencyType': self.deficiency_type,
            'tags': self.tags,
            'location': self.location,
            'likes': self.likes,
            'views': self.views,
            'commentCount': self.comment_count,
            'isPinned': self.is_pinned,
            'isSolved': self.is_solved,
            'createdAt': self.created_at,
            'updatedAt': self.updated_at
        }
    
    @staticmethod
    def from_dict(data: Dict[str, Any]) -> 'ForumPost':
        """Create ForumPost object from Firestore document."""
        return ForumPost(
            post_id=data.get('postId', ''),
            author_id=data.get('authorId', ''),
            title=data.get('title', ''),
            content=data.get('content', ''),
            category=data.get('category', ForumPost.CATEGORY_QUESTION),
            images=data.get('images', []),
            deficiency_type=data.get('deficiencyType'),
            tags=data.get('tags', []),
            location=data.get('location'),
            likes=data.get('likes', 0),
            views=data.get('views', 0),
            comment_count=data.get('commentCount', 0),
            is_pinned=data.get('isPinned', False),
            is_solved=data.get('isSolved', False),
            created_at=data.get('createdAt'),
            updated_at=data.get('updatedAt')
        )
    
    def increment_views(self):
        """Increment post view count."""
        self.views += 1
    
    def increment_likes(self):
        """Increment post like count."""
        self.likes += 1
        self.updated_at = datetime.utcnow()
    
    def decrement_likes(self):
        """Decrement post like count."""
        self.likes = max(0, self.likes - 1)
        self.updated_at = datetime.utcnow()
    
    def increment_comments(self):
        """Increment comment count."""
        self.comment_count += 1
        self.updated_at = datetime.utcnow()
    
    def decrement_comments(self):
        """Decrement comment count."""
        self.comment_count = max(0, self.comment_count - 1)
        self.updated_at = datetime.utcnow()
    
    def mark_as_solved(self):
        """Mark post as solved."""
        self.is_solved = True
        self.updated_at = datetime.utcnow()
    
    def pin(self):
        """Pin the post."""
        self.is_pinned = True
        self.updated_at = datetime.utcnow()
    
    def unpin(self):
        """Unpin the post."""
        self.is_pinned = False
        self.updated_at = datetime.utcnow()
    
    def add_tag(self, tag: str):
        """Add a tag to the post."""
        if tag not in self.tags:
            self.tags.append(tag)
            self.updated_at = datetime.utcnow()
    
    def remove_tag(self, tag: str):
        """Remove a tag from the post."""
        if tag in self.tags:
            self.tags.remove(tag)
            self.updated_at = datetime.utcnow()
    
    def __repr__(self):
        return f"<ForumPost '{self.title}' by {self.author_id}>"
