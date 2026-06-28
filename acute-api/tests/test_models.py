from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.doctor import Doctor


async def test_can_persist_and_load_doctor(db_session: AsyncSession) -> None:
    db_session.add(Doctor(mobile="911234567890", first_name="Asha", last_name="Rao"))
    await db_session.commit()
    rows = (await db_session.execute(select(Doctor))).scalars().all()
    assert len(rows) == 1
    assert rows[0].mobile == "911234567890"
