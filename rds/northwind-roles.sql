-- Copyright (c) HashiCorp, Inc.
-- SPDX-License-Identifier: MPL-2.0

begin;

  revoke all on schema public from public;

  create role northwind_analyst noinherit;
  grant usage on schema public to northwind_analyst;
  grant select on all tables in schema public to northwind_analyst;
  grant usage on all sequences in schema public to northwind_analyst;
  grant execute on all functions in schema public to northwind_analyst;

  create role northwind_dba noinherit;
  grant all privileges on database postgres to northwind_dba;

begin;

  -- Vault
  CREATE ROLE vault WITH LOGIN CREATEROLE;
  alter user vault password 'vault-password';
  GRANT "aws_rds_instance_postgresql_user_poc_vcb" TO vault;
commit;

