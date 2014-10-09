"""Allow access to the answer table."""
from sqlalchemy import Table, MetaData
from sqlalchemy.sql.dml import Insert

from db import engine
from db.question import get_question


answer_table = Table('answer', MetaData(bind=engine), autoload=True)


def answer_insert(*, answer, question_id: str, submission_id: str,
                  survey_id: str) -> Insert:
    """
    Insert a record into the answer table. An answer is associated with a
    question and a submission. Make sure to use a transaction!

    :param answer: The answer value. Can be one of the following types:
                   text,
                   integer,
                   decimal,
                   date,
                   time
    :param question_id: The UUID of the question.
    :param submission_id: The UUID of the submission.
    :param survey_id: The UUID of the survey.
    :return: The Insert object. Execute this!
    """
    question = get_question(question_id)
    type_constraint_name = question.type_constraint_name
    answer_type = 'answer_' + type_constraint_name
    values = {answer_type: answer,
              'question_id': question_id,
              'submission_id': submission_id,
              'type_constraint_name': type_constraint_name,
              'sequence_number': question.sequence_number,
              'allow_multiple': question.allow_multiple,
              'survey_id': survey_id}
    return answer_table.insert().values(values)
