/*Queries that provide answers to the questions from all projects.*/

SELECT * FROM animals WHERE name LIKE '%mon';

SELECT name FROM animals
WHERE date_of_birth BETWEEN '2016-01-01' AND '2019-12-31';

SELECT name FROM animals
WHERE neutered = true AND escape_attempts < 3;

SELECT date_of_birth FROM animals
WHERE name IN ('Agumon', 'Pikachu');

SELECT name, escape_attempts FROM animals
WHERE weight_kg > 10.5;

SELECT * FROM animals
WHERE neutered = true;

SELECT * FROM animals
WHERE name <> 'Gabumon';

SELECT * FROM animals
WHERE weight_kg BETWEEN 10.4 AND 17.3;

/* New queries */
-- First transaction

BEGIN;

UPDATE animals
SET species = 'unspecified';

SELECT * FROM animals;

ROLLBACK;

-- Second transaction
BEGIN;

UPDATE animals
SET species = 'digimon'
WHERE name LIKE '%mon';

UPDATE animals
SET species = 'pokemon'
WHERE species IS NULL;

SELECT * FROM animals;

COMMIT;

SELECT * FROM animals;

-- Third transaction
BEGIN;

DELETE FROM animals;

ROLLBACK;

SELECT * FROM animals;

-- forth transaction

BEGIN;

DELETE FROM animals
WHERE date_of_birth > '2022-01-01';

SAVEPOINT save_point_1;

UPDATE animals
SET weight_kg = weight_kg * -1;

ROLLBACK TO save_point_1;

UPDATE animals
SET weight_kg = weight_kg * -1
WHERE weight_kg < 0;

COMMIT;

-- Answers

-- How many animals are there?
SELECT COUNT(*) AS total_animals
FROM animals;

--How many animals have never tried to escape?
SELECT COUNT(*) AS animals_never_tried_to_escape
FROM animals
WHERE escape_attempts = 0;

-- What is the average weight of animals?
SELECT AVG(weight_kg) AS average_weight
FROM animals;

-- Who escapes the most, neutered or not neutered animals?
SELECT neutered, SUM(escape_attempts) AS total_escape_attempts
FROM animals
GROUP BY neutered
ORDER BY total_escape_attempts DESC
LIMIT 1;

-- What is the minimum and maximum weight of each type of animal?
SELECT species, MIN(weight_kg) AS min_weight, MAX(weight_kg) AS max_weight
FROM animals
GROUP BY species;

-- What is the average number of escape attempts per animal type of those born between 1990 and 2000?
SELECT species, AVG(escape_attempts) AS avg_escape_attempts
FROM animals
WHERE date_of_birth BETWEEN '1990-01-01' AND '2000-12-31'
GROUP BY species;

/* Answers using JOIN */
--What animals belong to Melody Pond?
SELECT animals.name AS animal_name
FROM animals
JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Melody Pond';

--List of all animals that are pokemon (their type is Pokemon).
SELECT animals.name AS animal_name
FROM animals
JOIN species ON animals.species_id = species.id
WHERE species.name = 'Pokemon';

--List all owners and their animals, remember to include those that don't own any animal.
SELECT owners.full_name, animals.name AS animal_name
FROM owners
LEFT JOIN animals ON owners.id = animals.owner_id;

--How many animals are there per species?
SELECT species.name, COUNT(animals.id) AS total_animals
FROM species
LEFT JOIN animals ON species.id = animals.species_id
GROUP BY species.name;

--List all Digimon owned by Jennifer Orwell.
SELECT animals.name AS digimon_name
FROM animals
JOIN species ON animals.species_id = species.id
JOIN owners ON animals.owner_id = owners.id
WHERE species.name = 'Digimon' AND owners.full_name = 'Jennifer Orwell';

--List all animals owned by Dean Winchester that haven't tried to escape.
SELECT animals.name AS animal_name
FROM animals
JOIN owners ON animals.owner_id = owners.id
WHERE owners.full_name = 'Dean Winchester' AND animals.escape_attempts = 0;

--Who owns the most animals?
SELECT owners.full_name, COUNT(animals.id) AS total_animals_owned
FROM owners
LEFT JOIN animals ON owners.id = animals.owner_id
GROUP BY owners.full_name
ORDER BY total_animals_owned DESC
LIMIT 1;

/* Answers */
--Who was the last animal seen by William Tatcher?
SELECT a.name AS animal_name
FROM visits v
JOIN animals a ON v.animal_id = a.id
JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'William Tatcher'
ORDER BY v.visit_date DESC
LIMIT 1;

--How many different animals did Stephanie Mendez see?
SELECT COUNT(DISTINCT v.animal_id) AS num_animals_seen
FROM visits v
JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'Stephanie Mendez';

--List all vets and their specialties, including vets with no specialties.
SELECT v.name AS vet_name, COALESCE(s.name, 'No Specialty') AS specialty
FROM vets v
LEFT JOIN specializations sp ON v.id = sp.vet_id
LEFT JOIN species s ON sp.species_id = s.id;

--List all animals that visited Stephanie Mendez between April 1st and August 30th, 2020.
SELECT a.name AS animal_name
FROM visits v
JOIN animals a ON v.animal_id = a.id
JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'Stephanie Mendez'
  AND v.visit_date BETWEEN '2020-04-01' AND '2020-08-30';

--What animal has the most visits to vets?
SELECT a.name AS animal_name, COUNT(*) AS num_visits
FROM visits v
JOIN animals a ON v.animal_id = a.id
GROUP BY a.name
ORDER BY num_visits DESC
LIMIT 1;

--Who was Maisy Smith's first visit?
SELECT a.name AS animal_name
FROM visits v
JOIN animals a ON v.animal_id = a.id
JOIN vets vt ON v.vet_id = vt.id
WHERE vt.name = 'Maisy Smith'
ORDER BY v.visit_date ASC
LIMIT 1;

--Details for most recent visit: animal information, vet information, and date of visit.
SELECT a.name AS animal_name, vt.name AS vet_name, v.visit_date
FROM visits v
JOIN animals a ON v.animal_id = a.id
JOIN vets vt ON v.vet_id = vt.id
ORDER BY v.visit_date DESC
LIMIT 1;

--How many visits were with a vet that did not specialize in that animal's species?
SELECT COUNT(*) AS num_visits
FROM visits v
JOIN animals a ON v.animal_id = a.id
JOIN vets vt ON v.vet_id = vt.id
LEFT JOIN specializations sp ON vt.id = sp.vet_id AND a.species_id = sp.species_id
WHERE sp.vet_id IS NULL;

--What specialty should Maisy Smith consider getting? Look for the species she gets the most.
SELECT s.name AS specialty_name
FROM animals a
JOIN visits v ON a.id = v.animal_id
JOIN vets vt ON v.vet_id = vt.id
JOIN species s ON a.species_id = s.id
WHERE vt.name = 'Maisy Smith'
GROUP BY s.name
ORDER BY COUNT(*) DESC
LIMIT 1;

