CREATE TABLE public.board_characters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  board_id uuid NOT NULL REFERENCES public.boards(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  visual_traits text NOT NULL DEFAULT '',
  consistency_notes text NOT NULL DEFAULT '',
  reference_image_paths text[] NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.board_characters TO authenticated;
GRANT ALL ON public.board_characters TO service_role;
ALTER TABLE public.board_characters ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Board owners manage characters" ON public.board_characters
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.boards b WHERE b.id = board_id AND b.user_id = auth.uid()))
  WITH CHECK (EXISTS (SELECT 1 FROM public.boards b WHERE b.id = board_id AND b.user_id = auth.uid()));

CREATE TABLE public.board_generation_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  board_id uuid NOT NULL REFERENCES public.boards(id) ON DELETE CASCADE,
  character_id uuid REFERENCES public.board_characters(id) ON DELETE SET NULL,
  kind text NOT NULL CHECK (kind IN ('image', 'video', 'prompt_assist', 'context_review')),
  status text NOT NULL DEFAULT 'queued' CHECK (status IN ('queued', 'running', 'completed', 'failed', 'cancelled')),
  model text NOT NULL,
  prompt text NOT NULL DEFAULT '',
  inputs jsonb NOT NULL DEFAULT '{}'::jsonb,
  output_path text,
  error text,
  provider_job_id text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.board_generation_runs TO authenticated;
GRANT ALL ON public.board_generation_runs TO service_role;
ALTER TABLE public.board_generation_runs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Board owners manage generation runs" ON public.board_generation_runs
  FOR ALL TO authenticated
  USING (EXISTS (SELECT 1 FROM public.boards b WHERE b.id = board_id AND b.user_id = auth.uid()))
  WITH CHECK (
    EXISTS (SELECT 1 FROM public.boards b WHERE b.id = board_id AND b.user_id = auth.uid())
    AND (character_id IS NULL OR EXISTS (
      SELECT 1 FROM public.board_characters c WHERE c.id = character_id AND c.board_id = board_id
    ))
  );

CREATE INDEX board_characters_board_id_idx ON public.board_characters(board_id);
CREATE INDEX board_generation_runs_board_created_idx ON public.board_generation_runs(board_id, created_at DESC);

CREATE OR REPLACE FUNCTION public.update_studio_updated_at()
RETURNS trigger
LANGUAGE plpgsql
SET search_path = public
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;
CREATE TRIGGER update_board_characters_updated_at
  BEFORE UPDATE ON public.board_characters
  FOR EACH ROW EXECUTE FUNCTION public.update_studio_updated_at();
CREATE TRIGGER update_board_generation_runs_updated_at
  BEFORE UPDATE ON public.board_generation_runs
  FOR EACH ROW EXECUTE FUNCTION public.update_studio_updated_at();