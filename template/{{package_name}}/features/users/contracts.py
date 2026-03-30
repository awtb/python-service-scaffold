from dataclasses import dataclass
from uuid import UUID


@dataclass(slots=True, kw_only=True)
class CreateUserCommand:
    email: str
    full_name: str


@dataclass(slots=True, kw_only=True)
class GetUserCommand:
    user_id: UUID


@dataclass(slots=True, kw_only=True)
class ListUsersCommand:
    page: int = 1
    page_size: int = 20
