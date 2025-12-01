"""
Forum User model for BananaDoc community forum.
"""

from datetime import datetime
from typing import Optional, Dict, Any


class ForumUser:
    """Represents a user in the farmer community forum."""
    
    def __init__(
        self,
        user_id: str,
        username: str,
        email: str,
        profile_picture: Optional[str] = None,
        location: Optional[str] = None,
        farm_size: Optional[str] = None,
        bio: Optional[str] = None,
        role: str = "farmer",
        reputation: int = 0,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None
    ):
        self.user_id = user_id
        self.username = username
        self.email = email
        self.profile_picture = profile_picture or ""
        self.location = location or ""
        self.farm_size = farm_size or ""
        self.bio = bio or ""
        self.role = role  # farmer, expert, admin
        self.reputation = reputation
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert user object to dictionary for Firestore."""
        return {
            'userId': self.user_id,
            'username': self.username,
            'email': self.email,
            'profilePicture': self.profile_picture,
            'location': self.location,
            'farmSize': self.farm_size,
            'bio': self.bio,
            'role': self.role,
            'reputation': self.reputation,
            'createdAt': self.created_at,
            'updatedAt': self.updated_at
        }
    
    @staticmethod
    def from_dict(data: Dict[str, Any]) -> 'ForumUser':
        """Create ForumUser object from Firestore document."""
        return ForumUser(
            user_id=data.get('userId', ''),
            username=data.get('username', ''),
            email=data.get('email', ''),
            profile_picture=data.get('profilePicture'),
            location=data.get('location'),
            farm_size=data.get('farmSize'),
            bio=data.get('bio'),
            role=data.get('role', 'farmer'),
            reputation=data.get('reputation', 0),
            created_at=data.get('createdAt'),
            updated_at=data.get('updatedAt')
        )
    
    def update_reputation(self, points: int):
        """Update user reputation score."""
        self.reputation += points
        self.updated_at = datetime.utcnow()
    
    def is_expert(self) -> bool:
        """Check if user has expert status."""
        return self.role == 'expert' or self.role == 'admin'
    
    def is_admin(self) -> bool:
        """Check if user has admin status."""
        return self.role == 'admin'
    
    def __repr__(self):
        return f"<ForumUser {self.username} ({self.role})>"
