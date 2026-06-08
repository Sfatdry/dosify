-- Ejecuta este script en el SQL Editor de Supabase

CREATE TABLE IF NOT EXISTS public.dosis_historial (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    medicamento_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    fecha_hora_programada timestamp with time zone NOT NULL,
    estado text DEFAULT 'PENDIENTE'::text NOT NULL,
    fecha_hora_toma timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT dosis_historial_pkey PRIMARY KEY (id),
    CONSTRAINT fk_medicamento FOREIGN KEY (medicamento_id) REFERENCES public.medicamento(id) ON DELETE CASCADE
);

-- Si deseas permitir que los usuarios lean/escriban a través del API (Row Level Security):
ALTER TABLE public.dosis_historial ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Los usuarios pueden ver su propio historial" 
ON public.dosis_historial FOR SELECT 
USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden insertar su propio historial" 
ON public.dosis_historial FOR INSERT 
WITH CHECK (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden actualizar su propio historial" 
ON public.dosis_historial FOR UPDATE 
USING (auth.uid() = usuario_id);

CREATE POLICY "Los usuarios pueden eliminar su propio historial" 
ON public.dosis_historial FOR DELETE 
USING (auth.uid() = usuario_id);
