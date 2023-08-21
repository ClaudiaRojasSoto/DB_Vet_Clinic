/* Database schema to keep the structure of entire database. */

CREATE DATABASE vet_clinic;

CREATE TABLE animals (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    date_of_birth DATE,
    escape_attempts INT,
    neutered BOOLEAN,
    weight_kg DECIMAL(5, 2)
);

/* Update animals table */

ALTER TABLE animals ADD species VARCHAR(50);

/* Adding new tables */

CREATE TABLE owners (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100),
    age INT
);

CREATE TABLE species (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100)
);

/* Change the animals table */

ALTER TABLE animals ALTER COLUMN id SET DEFAULT nextval('animals_id_seq');

ALTER TABLE animals DROP COLUMN species;

ALTER TABLE animals ADD COLUMN species_id INT REFERENCES species(id);

ALTER TABLE animals ADD COLUMN owner_id INT REFERENCES owners(id);


/* New tables in relations many-to-many */

CREATE TABLE vets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    age INT,
    date_of_graduation DATE
);

-- Join table between species and vets
CREATE TABLE specializations (
    vet_id INT REFERENCES vets(id),
    species_id INT REFERENCES species(id),
    PRIMARY KEY (vet_id, species_id)
);

-- Join table between animals and vets
CREATE TABLE visits (
    animal_id INT REFERENCES animals(id),
    vet_id INT REFERENCES vets(id),
    visit_date DATE,
    PRIMARY KEY (animal_id, vet_id)
);

ALTER TABLE visits DROP CONSTRAINT visits_pkey;

ALTER TABLE visits ADD PRIMARY KEY (animal_id, vet_id, visit_date);

ALTER TABLE owners ADD COLUMN email VARCHAR(120);

ALTER TABLE visits RENAME COLUMN visit_date TO date_of_visit;

ALTER TABLE visits ADD COLUMN id SERIAL;

TRUNCATE visits;
ALTER SEQUENCE visits_id_seq RESTART WITH 1;
INSERT INTO visits (animal_id, vet_id, date_of_visit) SELECT animal_id, vet_id, date_of_visit FROM temp_visits;
DROP TABLE temp_visits;
ALTER TABLE visits DROP CONSTRAINT visits_pkey;
ALTER TABLE visits ADD PRIMARY KEY (id);
INSERT INTO visits (animal_id, vet_id, date_of_visit)
SELECT animal_id, vet_id, visit_timestamp
FROM (SELECT id AS animal_id FROM animals) animal_ids
CROSS JOIN (SELECT id AS vet_id FROM vets) vets_ids
CROSS JOIN generate_series('1980-01-01'::timestamp, '2021-01-01', '4 hours') visit_timestamp;


-- This will add 3.594.280 visits considering you have 10 animals, 4 vets, and it will use around ~87.000 timestamps (~4min approx.)
INSERT INTO visits (animal_id, vet_id, date_of_visit) SELECT * FROM (SELECT id FROM animals) animal_ids, (SELECT id FROM vets) vets_ids, generate_series('1980-01-01'::timestamp, '2021-01-01', '4 hours') visit_timestamp;

-- This will add 2.500.000 owners with full_name = 'Owner <X>' and email = 'owner_<X>@email.com' (~2min approx.)
insert into owners (full_name, email) select 'Owner ' || generate_series(1,2500000), 'owner_' || generate_series(1,2500000) || '@mail.com';

-- This will add 3.594.280 visits considering you have 10 animals, 4 vets, and it will use around ~87.000 timestamps (~4min approx.)
INSERT INTO visits (animal_id, vet_id, date_of_visit) SELECT * FROM (SELECT id FROM animals) animal_ids, (SELECT id FROM vets) vets_ids, generate_series('1980-01-01'::timestamp, '2021-01-01', '4 hours') visit_timestamp;

-- This will add 2.500.000 owners with full_name = 'Owner <X>' and email = 'owner_<X>@email.com' (~2min approx.)
insert into owners (full_name, email) select 'Owner ' || generate_series(1,2500000), 'owner_' || generate_series(1,2500000) || '@mail.com';

-- This will add 3.594.280 visits considering you have 10 animals, 4 vets, and it will use around ~87.000 timestamps (~4min approx.)
INSERT INTO visits (animal_id, vet_id, date_of_visit) SELECT * FROM (SELECT id FROM animals) animal_ids, (SELECT id FROM vets) vets_ids, generate_series('1980-01-01'::timestamp, '2021-01-01', '4 hours') visit_timestamp;

-- This will add 2.500.000 owners with full_name = 'Owner <X>' and email = 'owner_<X>@email.com' (~2min approx.)
insert into owners (full_name, email) select 'Owner ' || generate_series(1,2500000), 'owner_' || generate_series(1,2500000) || '@mail.com';

CREATE INDEX idx_animal_id ON visits (animal_id);

CREATE INDEX idx_vet_id ON visits (vet_id);

CREATE INDEX idx_email ON owners (email);
