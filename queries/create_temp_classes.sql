CREATE PROCEDURE create_temp_classes()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS temp_classes;

    -- Create the temporary table
    CREATE TEMPORARY TABLE temp_classes (
        `class_id` INT PRIMARY KEY,
        `class_name` VARCHAR(255),
        `class_description` VARCHAR(255),
        `fk_class_level` INT,
        `fk_class_centre` INT,
        `class_to` DATETIME                 
        
    );

    -- Insert test data
    INSERT INTO temp_classes (class_id, `class_name`,class_description,fk_class_level,fk_class_centre) VALUES
(1223, "2024 Infant Joy", "", "10", "16"),
(1224, "2024 Playgroup Peace", "", "11", "16"),
(1225, "2024 Nursery 1 Love", "", "12", "16"),
(1226, "2024 Nursery 1 Honesty", "", "12", "16"),
(1227, "2024 Nursery 2 Unity", "", "13", "16"),
(1228, "2024 Kindergarten 1 Courage", "", "14", "16"),
(1229, "2024 Kindergarten 2 Patience", "", "15", "16"),
(1273, "2024 Playgroup Hope", "", "11", "16"),
(1283, "2025 Playgroup Emma Dodd", "Welcome to PG Emma Dodd ㋡ Documenting our learning in 2025 right here ♡", "11", "18"),
(1284, "2025 N1 Christie Matheson", "Welcome to N1 Christie Matheson ㋡ Documenting our learning in 2025 right here ♡  KINDLY DO REGULAR PHOTO DOWNLOADS!", "12", "18"),
(1285, "2025 N2 Eric Carle", "Welcome to N2 Eric Carle! ㋡ Documenting our learning in 2025 right here ♡", "13", "18"),
(1286, "2025 N2 Kevin Henkes", "Welcome to N2 Kevin Henkes ㋡ Documenting our learning in 2025 right here ♡", "13", "18"),
(1287, "2025 K1 Jo Empson", "Welcome to K1 Jo Empson! We are thrilled to have you join us on this exciting journey of learning, growth, and discovery. You can find updates on class activities, important announcements, and highlights of your child's work and creativity here! •ᴗ•", "14", "18"),
(1288, "2025 K2 Peter H.Reynolds", "Welcome to K2 Peter H.Reynolds ㋡ Documenting our learning in 2025 right here ♡", "15", "18"),
(1295, "2025 PG Rod Campbell", "", "11", "1"),
(1296, "2025 N1 Giles Andreae", "", "12", "1"),
(1297, "2025 N1 Marcus Pfister", "", "12", "1"),
(1298, "2025 N2 Eric Carle", "", "13", "1"),
(1300, "2025 K1 David McKee", "", "14", "1"),
(1301, "2025 K2 Debi Gliori", "", "15", "1"),
(1302, "2025 Infant Karen Katz", "", "10", "1"),
(1310, "2025 Infant Mozart", "", "10", "10"),
(1311, "2025 Playgroup Michael Rosen", "", "11", "10"),
(1312, "2025 Nursery 1 Lois Ehlert", "", "12", "10"),
(1313, "2025 Nursery 1 Taro Gomi", "", "12", "10"),
(1314, "2025 Nursery 2 Eric Carle", "", "13", "10"),
(1315, "2025 Kindergarten 1 Darwin", "", "14", "10"),
(1316, "2025 Kindergarten 2 Elgar", "", "15", "10"),
(1371, "2025 N2 Donaldson", "", "13", "20"),
(1376, "2025 Infant Joy", "", "10", "16"),
(1377, "2025 Playgroup Care", "", "11", "16"),
(1378, "2025 Playgroup Hope", "", "11", "16"),
(1379, "2025 Nursery 1 Grace", "", "12", "16"),
(1380, "2025 Nursery 1 Courage", "", "12", "16"),
(1381, "2025 Nursery 2 Love", "", "13", "16"),
(1382, "2025 Kindergarten 1 Gratitude", "", "14", "16"),
(1383, "2025 Kindergarten 2 Unity", "", "15", "16"),
(1395, "2025 PG Kale", "", "11", "20"),
(1397, "2025 PG Campbell", "", "11", "20"),
(1401, "2025 N1 Rosen", "", "12", "20"),
(1402, "2025 N1 Kelly", "", "12", "20"),
(1403, "2025 N2 Florence", "", "13", "20"),
(1404, "2025 K1 Bailey", "", "14", "20"),
(1405, "2025 Kindergarten 2 Risk-Takers", "", "15", "5"),
(1406, "2025 Kindergarten 1 Inventors", "", "14", "5"),
(1407, "2025 Nursery 2 Reflectors", "", "13", "5"),
(1408, "2025 Nursery 1 Engagers", "", "12", "5"),
(1409, "2025 Playgroup Explorers", "", "11", "5"),
(1430, "2025 K1 Bright", "", "14", "20"),
(1432, "2025 K2 Potter", "", "15", "20"),
(1433, "2025 K2 Robinson", "", "15", "20");


END;