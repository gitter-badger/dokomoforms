-- Table: question_branch

-- DROP TABLE question_branch;

CREATE TABLE question_branch
(
  question_branch_id     uuid    PRIMARY KEY DEFAULT uuid_generate_v4(),

  question_choice_id     uuid    NOT NULL,

  from_question_id       uuid    NOT NULL,
  from_type_constraint   text    NOT NULL,
  from_sequence_number   integer NOT NULL,
  from_allow_multiple    boolean NOT NULL,
  from_survey_id         uuid    NOT NULL,

  to_question_id         uuid    NOT NULL,
  to_type_constraint     text    NOT NULL,
  to_sequence_number     integer NOT NULL,
  to_allow_multiple      boolean NOT NULL,
  to_survey_id           uuid    NOT NULL,

  last_update_time       timestamp with time zone NOT NULL DEFAULT now(),

  FOREIGN KEY(question_choice_id,
              from_question_id,
              from_type_constraint,
              from_sequence_number,
              from_allow_multiple,
              from_survey_id)
                REFERENCES question_choice
             (question_choice_id,
              question_id,
              type_constraint_name,
              question_sequence_number,
              allow_multiple,
              survey_id) ON UPDATE CASCADE ON DELETE CASCADE,

  FOREIGN KEY(to_question_id,
              to_type_constraint,
              to_sequence_number,
              to_allow_multiple,
              to_survey_id)
                REFERENCES question
             (question_id,
              type_constraint_name,
              sequence_number,
              allow_multiple,
              survey_id) ON UPDATE CASCADE ON DELETE CASCADE,

  -- You can't have two entries for the same choice.
  UNIQUE(from_question_id, question_choice_id),

  CONSTRAINT cannot_allow_multiple CHECK(NOT from_allow_multiple),

  CONSTRAINT cannot_point_backward CHECK(
    to_sequence_number > from_sequence_number
  ),

  CONSTRAINT cannot_point_to_another_survey CHECK(
    from_survey_id = to_survey_id
  ),

  CONSTRAINT question_could_have_choices CHECK(
    from_type_constraint = 'multiple_choice'
  ) 
)
WITH (
  OIDS=FALSE
);
ALTER TABLE question
  OWNER TO postgres;

