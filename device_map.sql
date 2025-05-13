/*
 * Copyright (c) 2022, Brian A. McKenzie <mckenzba@gmail.com>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* 
 * Targets table schema.
 */
CREATE TABLE Targets
(
    Target
        TEXT
        COLLATE NOCASE
	PRIMARY KEY
	UNIQUE
 	NOT NULL,
    TargetType
        TEXT
        NOT NULL,
    Platform
        TEXT
        COLLATE NOCASE
        NOT NULL,
    ProductType
        TEXT
        COLLATE NOCASE,
    KernelMachOArchitecture TEXT,
    KernelPlatform TEXT,
    SDKPlatform TEXT,
    ChipID TEXT,
    BoardID TEXT
);

/*
 * Manifests table schema.
 */
CREATE TABLE Manifests
(
    manifestId
        INTEGER
        PRIMARY KEY
        UNIQUE
        NOT NULL,
    Target
        TEXT
        COLLATE NOCASE
        REFERENCES Targets (Target)
        NOT NULL
);

/*
 * Files table schema.
 */
CREATE TABLE Files
(
    manifestId
        TEXT
        REFERENCES Manifests (manifestId)
        NOT NULL,
    fileType
        TEXT
        COLLATE NOCASE
        NOT NULL
);

/*
 * Trigger for updating the Manifests table
 * after an insert on the Targets table.
 */
CREATE TRIGGER insert_into_manifests AFTER INSERT ON Targets
BEGIN
    INSERT INTO Manifests (Target)
        SELECT Target from Targets t
        WHERE NOT EXISTS (SELECT Target from Manifests m WHERE m.Target = t.Target);
END;

/*
 * Trigger for updating the Files table
 * after an insert on the Manifests table.
 */
CREATE TRIGGER insert_into_files AFTER INSERT ON Manifests
BEGIN
    INSERT INTO Files (manifestId, fileType)
        SELECT m.manifestId, "KernelCache" as fileType FROM Manifests m INNER JOIN Targets t ON t.Target == m.Target
        WHERE NOT EXISTS (SELECT manifestId, fileType FROM Files f WHERE f.manifestId = m.manifestId AND f.fileType = "KernelCache")
        UNION
        SELECT m.manifestId, "RestoreKernelCache" as fileType FROM Manifests m INNER JOIN Targets t ON t.Target == m.Target
        WHERE NOT EXISTS (SELECT manifestId, fileType FROM Files f WHERE f.manifestId = m.manifestId AND f.fileType = "RestoreKernelCache");
END;

/*
 * Populate the Targets table from targets csv.
 */
.mode csv
.import targets.csv Targets
