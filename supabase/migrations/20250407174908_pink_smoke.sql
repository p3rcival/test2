/*
  # Initial Schema Setup

  1. Tables
    - exercise_templates
    - workout_schedules

  2. Security
    - RLS policies for both tables
    - Updated triggers
*/

-- Create exercise_templates table
CREATE TABLE IF NOT EXISTS exercise_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  name text NOT NULL,
  sets integer NOT NULL,
  reps integer NOT NULL,
  weight numeric,
  video_urls text[],
  notes text,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE exercise_templates ENABLE ROW LEVEL SECURITY;

-- Create policies for exercise_templates
CREATE POLICY "Users can create own templates"
  ON exercise_templates FOR INSERT 
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own templates"
  ON exercise_templates FOR SELECT 
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own templates"
  ON exercise_templates FOR UPDATE 
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own templates"
  ON exercise_templates FOR DELETE 
  TO authenticated
  USING (auth.uid() = user_id);

-- Create workout_schedules table
CREATE TABLE IF NOT EXISTS workout_schedules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id),
  date date NOT NULL,
  exercises jsonb NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, date)
);

-- Enable RLS
ALTER TABLE workout_schedules ENABLE ROW LEVEL SECURITY;

-- Create policies for workout_schedules
CREATE POLICY "Users can create own schedules"
  ON workout_schedules FOR INSERT 
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read own schedules"
  ON workout_schedules FOR SELECT 
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own schedules"
  ON workout_schedules FOR UPDATE 
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own schedules"
  ON workout_schedules FOR DELETE 
  TO authenticated
  USING (auth.uid() = user_id);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for workout_schedules
CREATE TRIGGER update_workout_schedules_updated_at
  BEFORE UPDATE ON workout_schedules
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();