BEGIN;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

INSERT INTO "policy" (
    "index",
    "name",
    "min_admission_time",
    "max_admission_time",
    "discussion_time",
    "verification_time",
    "voting_time",
    "issue_quorum_num", "issue_quorum_den",
    "initiative_quorum_num", "initiative_quorum_den",
    "direct_majority_num", "direct_majority_den", "direct_majority_strict",
    "no_reverse_beat_path", "no_multistage_majority"
  ) VALUES (
    1,
    'Default policy',
    '0', '1 hour', '1 hour', '1 hour', '1 hour',
    25, 100,
    20, 100,
    1, 2, TRUE,
    TRUE, FALSE );

INSERT INTO "unit" ("name") VALUES ('Main'), ('Other');

INSERT INTO "privilege" ("unit_id", "member_id", "voting_right")
  SELECT 1 AS "unit_id", "id" AS "member_id", TRUE AS "voting_right"
  FROM "member";
INSERT INTO "privilege" ("unit_id", "member_id", "voting_right") VALUES
  (2, 1, TRUE), (2, 2, TRUE), (2, 3, TRUE);

INSERT INTO "area" ("unit_id", "name") VALUES
  (1, 'Area #1'),  -- id 1
  (1, 'Area #2'),  -- id 2
  (1, 'Area #3'),  -- id 3
  (1, 'Area #4'),  -- id 4
  (2, 'Area #5');  -- id 5

INSERT INTO "allowed_policy" ("area_id", "policy_id", "default_policy")
  VALUES (1, 1, TRUE), (2, 1, TRUE), (3, 1, TRUE), (4, 1, TRUE), (5, 1, TRUE);

INSERT INTO "membership" ("area_id", "member_id") VALUES
  (1,  9),
  (1, 19),
  (2,  9),
  (2, 10),
  (2, 17),
  (3,  9),
  (3, 11),
  (3, 12),
  (3, 14),
  (3, 20),
  (3, 21),
  (3, 22),
  (4,  6),
  (4,  9),
  (4, 13),
  (4, 22),
  (5, 1),
  (5, 2);

-- global delegations
INSERT INTO "delegation"
  ("truster_id", "scope", "unit_id", "trustee_id") VALUES
  ( 1, 'unit', 1,  9),
  ( 2, 'unit', 1, 11),
  ( 3, 'unit', 1, 12),
  ( 4, 'unit', 1, 13),
  ( 5, 'unit', 1, 14),
  ( 6, 'unit', 1,  7),
  ( 7, 'unit', 1,  8),
  ( 8, 'unit', 1,  6),
  (10, 'unit', 1,  9),
  (11, 'unit', 1,  9),
  (12, 'unit', 1, 21),
  (15, 'unit', 1, 10),
  (16, 'unit', 1, 17),
  (17, 'unit', 1, 19),
  (18, 'unit', 1, 19),
  (23, 'unit', 1, 22);

-- delegations for topics
INSERT INTO "delegation"
  ("area_id", "truster_id", "scope", "trustee_id") VALUES
  (1,  3, 'area', 17),
  (2,  5, 'area', 10),
  (2,  9, 'area', 10),
  (3,  4, 'area', 14),
  (3, 16, 'area', 20),
  (3, 19, 'area', 20),
  (4,  5, 'area', 13),
  (4, 12, 'area', 22);

INSERT INTO "issue" ("area_id", "policy_id") VALUES
  (3, 1);  -- id 1

INSERT INTO "initiative" ("issue_id", "name") VALUES
  (1, 'Initiative #1'),  -- id 1
  (1, 'Initiative #2'),  -- id 2
  (1, 'Initiative #3'),  -- id 3
  (1, 'Initiative #4'),  -- id 4
  (1, 'Initiative #5'),  -- id 5
  (1, 'Initiative #6'),  -- id 6
  (1, 'Initiative #7');  -- id 7

INSERT INTO "draft" ("initiative_id", "author_id", "content") VALUES
  (1, 17, 'Lorem ipsum...'),  -- id 1
  (2, 20, 'Lorem ipsum...'),  -- id 2
  (3, 20, 'Lorem ipsum...'),  -- id 3
  (4, 20, 'Lorem ipsum...'),  -- id 4
  (5, 14, 'Lorem ipsum...'),  -- id 5
  (6, 11, 'Lorem ipsum...'),  -- id 6
  (7, 12, 'Lorem ipsum...');  -- id 7

INSERT INTO "initiator" ("initiative_id", "member_id") VALUES
  (1, 17),
  (1, 19),
  (2, 20),
  (3, 20),
  (4, 20),
  (5, 14),
  (6, 11),
  (7, 12);

INSERT INTO "supporter" ("member_id", "initiative_id", "draft_id") VALUES
  ( 7,  4,  4),
  ( 8,  2,  2),
  (11,  6,  6),
  (12,  7,  7),
  (14,  1,  1),
  (14,  2,  2),
  (14,  3,  3),
  (14,  4,  4),
  (14,  5,  5),
  (14,  6,  6),
  (14,  7,  7),
  (17,  1,  1),
  (17,  3,  3),
  (19,  1,  1),
  (19,  2,  2),
  (20,  1,  1),
  (20,  2,  2),
  (20,  3,  3),
  (20,  4,  4),
  (20,  5,  5);

INSERT INTO "suggestion" ("initiative_id", "author_id", "name", "content") VALUES
  (1, 19, 'Suggestion #1', 'Lorem ipsum...');  -- id 1
INSERT INTO "opinion" ("member_id", "suggestion_id", "degree", "fulfilled") VALUES
  (14, 1, 2, FALSE);
INSERT INTO "opinion" ("member_id", "suggestion_id", "degree", "fulfilled") VALUES
  (19, 1, 2, FALSE);

INSERT INTO "issue" ("area_id", "policy_id") VALUES
  (4, 1);  -- id 2

INSERT INTO "initiative" ("issue_id", "name") VALUES
  (2, 'Initiative A'),  -- id  8
  (2, 'Initiative B'),  -- id  9
  (2, 'Initiative C'),  -- id 10
  (2, 'Initiative D');  -- id 11

INSERT INTO "draft" ("initiative_id", "author_id", "content") VALUES
  ( 8, 1, 'Lorem ipsum...'),  -- id  8
  ( 9, 2, 'Lorem ipsum...'),  -- id  9
  (10, 3, 'Lorem ipsum...'),  -- id 10
  (11, 4, 'Lorem ipsum...');  -- id 11

INSERT INTO "initiator" ("initiative_id", "member_id") VALUES
  ( 8, 1),
  ( 9, 2),
  (10, 3),
  (11, 4);

INSERT INTO "supporter" ("member_id", "initiative_id", "draft_id") VALUES
  (1,  8,  8),
  (1,  9,  9),
  (1, 10, 10),
  (1, 11, 11),
  (2,  8,  8),
  (2,  9,  9),
  (2, 10, 10),
  (2, 11, 11),
  (3,  8,  8),
  (3,  9,  9),
  (3, 10, 10),
  (3, 11, 11),
  (4,  8,  8),
  (4,  9,  9),
  (4, 10, 10),
  (4, 11, 11),
  (5,  8,  8),
  (5,  9,  9),
  (5, 10, 10),
  (5, 11, 11),
  (6,  8,  8),
  (6,  9,  9),
  (6, 10, 10),
  (6, 11, 11);
 
SELECT "time_warp"('1 hour 1 minute');
SELECT "time_warp"('1 hour 1 minute');
SELECT "time_warp"('1 hour 1 minute');

END;

