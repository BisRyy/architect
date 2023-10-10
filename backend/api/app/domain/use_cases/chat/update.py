from api.core.use_cases.use_case import UseCase
from api.app.domain.repositories.chat import BaseRepository
from api.core.common.equatable import Equatable
from core.common.either import Either
from core.errors.failure import Failure
from app.domain.entities.chat import Chat, ChatEntity

class Params(Equatable):
    def __init__(self, chat: ChatEntity) -> None:
        self.chat = chat


class UpdateChat(UseCase[Chat]):
    def __init__(self, repository: BaseRepository):
        self.repository = repository
    
    async def __call__(self, params: Params) -> Either[Failure, Chat]:
        return await self.repository.update_chat(params.chat)