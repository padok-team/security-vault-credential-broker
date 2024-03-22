-- Copyright (c) HashiCorp, Inc.
-- SPDX-License-Identifier: MPL-2.0

begin;

  revoke all on schema public from public;

  create role dev noinherit;
  grant usage on schema public to dev;
  grant select, insert, update, delete on all tables in schema public to dev;
  grant select, usage, update on all sequences in schema public to dev;
  grant execute on all functions in schema public to dev;

  create role ops noinherit;
  grant all privileges on database postgres to ops;

begin;

  -- Vault
  CREATE ROLE vault WITH LOGIN CREATEROLE;
  alter user vault password 'vault-password';
  GRANT "aws_rds_instance_postgresql_user_poc_vcb" TO vault;
commit;

