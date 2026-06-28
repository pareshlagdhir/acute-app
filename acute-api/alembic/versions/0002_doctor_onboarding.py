"""doctor onboarding tables + catalog seed

Revision ID: 0002_doctor_onboarding
Revises: 0001
Create Date: 2026-06-28
"""
import uuid

import sqlalchemy as sa

from alembic import op

revision = "0002_doctor_onboarding"
down_revision = "0001"
branch_labels = None
depends_on = None

DEGREES = ["MBBS", "MD", "MS", "DM", "MCh", "DNB", "BDS", "MDS", "DGO", "DA"]
SPECIALITIES = [
    "General Medicine", "Cardiology", "Orthopaedics", "Paediatrics",
    "Gynaecology", "Dermatology", "Neurology", "Oncology", "Radiology",
    "Anaesthesiology", "ENT", "Ophthalmology",
]


def upgrade() -> None:
    op.create_table(
        "doctors",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("mobile", sa.String(20), nullable=False, unique=True),
        sa.Column("first_name", sa.String(100)),
        sa.Column("middle_name", sa.String(100)),
        sa.Column("last_name", sa.String(100)),
        sa.Column("email", sa.String(255)),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_doctors_mobile", "doctors", ["mobile"])

    op.create_table(
        "degree_catalog",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
    )
    op.create_table(
        "speciality_catalog",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False, unique=True),
    )
    op.create_table(
        "hospitals",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("name", sa.String(255), nullable=False),
        sa.Column("type", sa.String(20), nullable=False, server_default="hospital"),
        sa.Column("city", sa.String(120)),
        sa.Column("address", sa.String(500)),
        sa.Column("created_by", sa.Uuid()),
    )
    op.create_index("ix_hospitals_name", "hospitals", ["name"])

    op.create_table(
        "doctor_educations",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("degree", sa.String(100), nullable=False),
        sa.Column("registration_number", sa.String(100), nullable=False),
        sa.Column("institution", sa.String(255)),
        sa.Column("year_of_completion", sa.Integer()),
    )
    op.create_table(
        "doctor_specialities",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
    )
    op.create_table(
        "doctor_experiences",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("doctor_id", sa.Uuid(), sa.ForeignKey("doctors.id", ondelete="CASCADE"), nullable=False),
        sa.Column("hospital_id", sa.Uuid(), sa.ForeignKey("hospitals.id"), nullable=False),
        sa.Column("designation", sa.String(120)),
        sa.Column("start_date", sa.Date()),
        sa.Column("end_date", sa.Date()),
        sa.Column("is_current", sa.Boolean(), nullable=False, server_default=sa.false()),
    )
    op.create_table(
        "working_hours",
        sa.Column("id", sa.Uuid(), primary_key=True),
        sa.Column("experience_id", sa.Uuid(), sa.ForeignKey("doctor_experiences.id", ondelete="CASCADE"), nullable=False),
        sa.Column("day_of_week", sa.Integer(), nullable=False),
        sa.Column("start_time", sa.Time(), nullable=False),
        sa.Column("end_time", sa.Time(), nullable=False),
    )

    degrees = sa.table("degree_catalog", sa.column("id", sa.Uuid()), sa.column("name", sa.String))
    specialities = sa.table("speciality_catalog", sa.column("id", sa.Uuid()), sa.column("name", sa.String))
    op.bulk_insert(degrees, [{"id": uuid.uuid4(), "name": n} for n in DEGREES])
    op.bulk_insert(specialities, [{"id": uuid.uuid4(), "name": n} for n in SPECIALITIES])


def downgrade() -> None:
    for tbl in (
        "working_hours", "doctor_experiences", "doctor_specialities",
        "doctor_educations", "hospitals", "speciality_catalog",
        "degree_catalog", "doctors",
    ):
        op.drop_table(tbl)
