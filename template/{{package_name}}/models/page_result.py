from dataclasses import dataclass
from typing import Generic, TypeVar

from .base import BaseModel

ModelT = TypeVar("ModelT", bound=BaseModel)


@dataclass(slots=True)
class PageResult(Generic[ModelT]):
    items: list[ModelT]
    total_pages: int
    page: int
    page_size: int
    total_items: int
