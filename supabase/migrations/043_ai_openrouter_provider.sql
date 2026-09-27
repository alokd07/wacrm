-- ============================================================
-- 043_ai_openrouter_provider.sql — Support OpenRouter AI provider
--
-- Expands the provider CHECK constraints on `ai_configs` and
-- `ai_usage_log` to allow 'openrouter' in addition to 'openai'
-- and 'anthropic'.
--
-- Idempotent — safe to run multiple times.
-- ============================================================

DO $$
DECLARE
  r RECORD;
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables WHERE table_name = 'ai_configs'
  ) THEN
    FOR r IN (
      SELECT conname
      FROM pg_constraint con
      JOIN pg_class rel ON rel.oid = con.conrelid
      JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
      WHERE rel.relname = 'ai_configs' AND con.contype = 'c' AND pg_get_constraintdef(con.oid) LIKE '%provider%'
    ) LOOP
      EXECUTE 'ALTER TABLE ai_configs DROP CONSTRAINT IF EXISTS ' || quote_ident(r.conname);
    END LOOP;

    ALTER TABLE ai_configs ADD CONSTRAINT ai_configs_provider_check CHECK (provider IN ('openai', 'anthropic', 'openrouter'));
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.tables WHERE table_name = 'ai_usage_log'
  ) THEN
    FOR r IN (
      SELECT conname
      FROM pg_constraint con
      JOIN pg_class rel ON rel.oid = con.conrelid
      JOIN pg_namespace nsp ON nsp.oid = rel.relnamespace
      WHERE rel.relname = 'ai_usage_log' AND con.contype = 'c' AND pg_get_constraintdef(con.oid) LIKE '%provider%'
    ) LOOP
      EXECUTE 'ALTER TABLE ai_usage_log DROP CONSTRAINT IF EXISTS ' || quote_ident(r.conname);
    END LOOP;

    ALTER TABLE ai_usage_log ADD CONSTRAINT ai_usage_log_provider_check CHECK (provider IN ('openai', 'anthropic', 'openrouter'));
  END IF;
END $$;
