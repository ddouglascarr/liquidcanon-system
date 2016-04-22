-- Database modifications necessary for liquid-canon
DROP TABLE IF EXISTS "unit_permissions";
CREATE TABLE "unit_permissions" (
        "id"            SERIAL4         PRIMARY KEY,
        "unit_id"       SERIAL4         UNIQUE,
        FOREIGN KEY ("unit_id") REFERENCES "unit" ("id"),
        "public_read"   BOOLEAN         NOT NULL);
COMMENT ON COLUMN "unit_permissions"."public_read" IS 'Set to TRUE if only members can read data from unit';

CREATE OR REPLACE VIEW "member_unit_privilege" AS
  SELECT 
    "unit"."id" AS "unit_id",
    "member"."id" AS "member_id"
    FROM (SELECT * FROM "member" WHERE "active") AS "member"
    JOIN "privilege"
      ON "privilege"."member_id" = "member"."id"
    JOIN "unit"
      ON "privilege"."unit_id" = "unit"."id";

CREATE OR REPLACE VIEW "member_area_privilege" AS
  SELECT
    "privileges"."member_id" AS "member_id",
    "area"."id" AS "area_id"
    FROM "member_unit_privilege" AS "privileges"
    JOIN "area"
      ON "area"."unit_id" = "privileges"."unit_id";

CREATE OR REPLACE FUNCTION "unit_with_read_privilege"
  ( "member_id_p"       "member"."id"%TYPE,
    "unit_id_p"         "unit"."id"%TYPE)
  RETURNS "unit"
  LANGUAGE 'plpgsql' AS $$
    DECLARE
      "is_public_read"    BOOLEAN;
      "output_row"        "unit"%ROWTYPE;
      "privilege_row"     "privilege"%ROWTYPE;
    BEGIN
      SELECT INTO "output_row" * FROM "unit" WHERE "unit"."id" = "unit_id_p";
      IF "output_row"."id" ISNULL THEN
        RAISE EXCEPTION 'no_data_found';
      END IF;
      SELECT INTO "is_public_read" "public_read" FROM "unit_permissions"
        WHERE "unit_permissions"."unit_id" = "unit_id_p";
      IF "is_public_read" THEN
        RETURN "output_row";
      END IF;
      SELECT INTO "privilege_row" * FROM "privilege"
        WHERE "unit_id" = "unit_id_p"
        AND "member_id" = "member_id_p";
      IF "privilege_row"."unit_id" NOTNULL THEN
        RETURN "output_row";
      END IF;
      RAISE EXCEPTION 'insufficient_privilege';
    END;
  $$;
      
