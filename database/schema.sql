-- WARNING: This schema is for context only and is not meant to be run.
-- Table order and constraints may not be valid for execution.

CREATE TABLE public.usuario (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nombre character varying,
  email character varying NOT NULL UNIQUE,
  password text NOT NULL,
  fecha_registro timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT usuario_pkey PRIMARY KEY (id)
);
CREATE TABLE public.tratamiento (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  usuario_id uuid,
  nombre character varying,
  fecha_inicio date,
  fecha_fin date,
  estado character varying DEFAULT 'activo'::character varying,
  recordatorio_activo boolean DEFAULT true,
  repeticiones integer DEFAULT 1,
  tipo_alerta text DEFAULT 'NORMAL'::text,
  CONSTRAINT tratamiento_pkey PRIMARY KEY (id),
  CONSTRAINT tratamiento_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id)
);
CREATE TABLE public.medicamento (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tratamiento_id uuid,
  nombre character varying NOT NULL,
  dosis character varying,
  frecuencia_horas integer,
  duracion_dias integer,
  es_critico boolean DEFAULT false,
  CONSTRAINT medicamento_pkey PRIMARY KEY (id),
  CONSTRAINT medicamento_tratamiento_id_fkey FOREIGN KEY (tratamiento_id) REFERENCES public.tratamiento(id)
);
CREATE TABLE public.dosis (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  medicamento_id uuid,
  fecha_hora timestamp without time zone,
  estado character varying CHECK (estado::text = ANY (ARRAY['pendiente'::character varying, 'tomada'::character varying, 'omitida'::character varying, 'tarde'::character varying]::text[])),
  CONSTRAINT dosis_pkey PRIMARY KEY (id),
  CONSTRAINT dosis_medicamento_id_fkey FOREIGN KEY (medicamento_id) REFERENCES public.medicamento(id)
);
CREATE TABLE public.recordatorio (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  medicamento_id uuid,
  fecha_hora timestamp without time zone,
  activo boolean DEFAULT true,
  CONSTRAINT recordatorio_pkey PRIMARY KEY (id),
  CONSTRAINT recordatorio_medicamento_id_fkey FOREIGN KEY (medicamento_id) REFERENCES public.medicamento(id)
);
CREATE TABLE public.inventario (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  medicamento_id uuid,
  cantidad_inicial integer,
  cantidad_actual integer,
  alerta_minima integer DEFAULT 5,
  CONSTRAINT inventario_pkey PRIMARY KEY (id),
  CONSTRAINT inventario_medicamento_id_fkey FOREIGN KEY (medicamento_id) REFERENCES public.medicamento(id)
);
CREATE TABLE public.farmacia (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  nombre character varying,
  direccion text,
  latitud numeric,
  longitud numeric,
  CONSTRAINT farmacia_pkey PRIMARY KEY (id)
);
CREATE TABLE public.dieta (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tratamiento_id uuid,
  descripcion text,
  fecha_inicio date,
  fecha_fin date,
  CONSTRAINT dieta_pkey PRIMARY KEY (id),
  CONSTRAINT dieta_tratamiento_id_fkey FOREIGN KEY (tratamiento_id) REFERENCES public.tratamiento(id)
);
CREATE TABLE public.notavoz (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tratamiento_id uuid,
  url_audio text,
  fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT notavoz_pkey PRIMARY KEY (id),
  CONSTRAINT notavoz_tratamiento_id_fkey FOREIGN KEY (tratamiento_id) REFERENCES public.tratamiento(id)
);
CREATE TABLE public.historialcumplimiento (
  id uuid NOT NULL DEFAULT gen_random_uuid(),
  tratamiento_id uuid,
  porcentaje_cumplimiento numeric,
  dosis_a_tiempo integer,
  dosis_tarde integer,
  dosis_omitidas integer,
  fecha timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT historialcumplimiento_pkey PRIMARY KEY (id),
  CONSTRAINT historialcumplimiento_tratamiento_id_fkey FOREIGN KEY (tratamiento_id) REFERENCES public.tratamiento(id)
);

-- TRIGGER PARA ACTUALIZAR EL INVENTARIO EN TIEMPO REAL
-- 1. Función para recalcular cantidad_actual basado en dosis tomadas/tarde
CREATE OR REPLACE FUNCTION public.recalcular_stock_inventario(med_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.inventario
    SET cantidad_actual = COALESCE(
        cantidad_inicial - (
            SELECT COUNT(*)
            FROM public.dosis
            WHERE medicamento_id = med_id AND estado IN ('tomada', 'tarde')
        ),
        cantidad_inicial
    )
    WHERE medicamento_id = med_id;
END;
$$ LANGUAGE plpgsql;

-- 2. Función del trigger para dosis
CREATE OR REPLACE FUNCTION public.trigger_actualizar_stock_dosis()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM public.recalcular_stock_inventario(NEW.medicamento_id);
        RETURN NEW;
    ELSIF TG_OP = 'UPDATE' THEN
        PERFORM public.recalcular_stock_inventario(NEW.medicamento_id);
        IF OLD.medicamento_id <> NEW.medicamento_id THEN
            PERFORM public.recalcular_stock_inventario(OLD.medicamento_id);
        END IF;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM public.recalcular_stock_inventario(OLD.medicamento_id);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- 3. Vincular el trigger a la tabla dosis
DROP TRIGGER IF EXISTS trg_actualizar_stock_dosis ON public.dosis;
CREATE TRIGGER trg_actualizar_stock_dosis
AFTER INSERT OR UPDATE OR DELETE ON public.dosis
FOR EACH ROW
EXECUTE FUNCTION public.trigger_actualizar_stock_dosis();