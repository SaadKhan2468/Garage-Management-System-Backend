PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS "Customer" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "firstName" TEXT NOT NULL,
    "lastName" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT NOT NULL,
    "company" TEXT,
    "notes" TEXT,
    "addressLine1" TEXT,
    "addressLine2" TEXT,
    "city" TEXT,
    "state" TEXT,
    "postalCode" TEXT
);
INSERT INTO Customer VALUES(4,1760793282216,1760793282216,'John','Doe','john.doe@example.com','555-0100',NULL,NULL,'123 Main St',NULL,'Springfield','CA','90210');
CREATE TABLE IF NOT EXISTS "Vehicle" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "customerId" INTEGER NOT NULL,
    "vin" TEXT NOT NULL,
    "make" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "year" INTEGER NOT NULL,
    "licensePlate" TEXT,
    "mileage" INTEGER,
    "color" TEXT,
    "engine" TEXT,
    "notes" TEXT,
    CONSTRAINT "Vehicle_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "Customer" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO Vehicle VALUES(4,1760793282216,1760793282216,4,'1HGBH41JXMN109186','Honda','Civic',2018,'ABC123',45000,'Blue',NULL,NULL);
CREATE TABLE IF NOT EXISTS "WorkOrder" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "code" TEXT NOT NULL,
    "customerId" INTEGER,
    "vehicleId" INTEGER NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "description" TEXT NOT NULL,
    "scheduledDate" DATETIME,
    "completedDate" DATETIME,
    "laborCost" DECIMAL NOT NULL DEFAULT 0,
    "partsCost" DECIMAL NOT NULL DEFAULT 0,
    "taxes" DECIMAL NOT NULL DEFAULT 0,
    "discount" DECIMAL NOT NULL DEFAULT 0,
    "totalCost" DECIMAL NOT NULL DEFAULT 0,
    "notes" TEXT,
    "parkingCharge" DECIMAL NOT NULL DEFAULT 0,
    "arrivalDate" DATETIME,
    "quotedAt" DATETIME,
    "isHistorical" BOOLEAN NOT NULL DEFAULT false,
    CONSTRAINT "WorkOrder_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "Customer" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "WorkOrder_vehicleId_fkey" FOREIGN KEY ("vehicleId") REFERENCES "Vehicle" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO WorkOrder VALUES(3,1760793282239,1760793942115,'WO-00001',4,4,'COMPLETED','Full service and brake inspection',1760793282228,1760793942113,200,130,30,0,375,NULL,15,1760789682228,1760793282228,1);
CREATE TABLE IF NOT EXISTS "WorkOrderLineItem" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workOrderId" INTEGER NOT NULL,
    "inventoryItemId" INTEGER,
    "serviceItemId" INTEGER,
    "description" TEXT NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 1,
    "unitPrice" DECIMAL NOT NULL DEFAULT 0,
    "lineTotal" DECIMAL NOT NULL DEFAULT 0,
    CONSTRAINT "WorkOrderLineItem_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES "WorkOrder" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "WorkOrderLineItem_inventoryItemId_fkey" FOREIGN KEY ("inventoryItemId") REFERENCES "InventoryItem" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT "WorkOrderLineItem_serviceItemId_fkey" FOREIGN KEY ("serviceItemId") REFERENCES "ServiceItem" ("id") ON DELETE SET NULL ON UPDATE CASCADE
);
INSERT INTO WorkOrderLineItem VALUES(7,1760793282239,3,NULL,4,'Brake Inspection Labour',1,200,200);
INSERT INTO WorkOrderLineItem VALUES(8,1760793282239,3,5,NULL,'Brake Pads Replacement',1,85,85);
INSERT INTO WorkOrderLineItem VALUES(9,1760793282239,3,4,NULL,'Engine Oil (5W-30)',1,45,45);
CREATE TABLE IF NOT EXISTS "InventoryItem" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "name" TEXT NOT NULL,
    "sku" TEXT NOT NULL,
    "description" TEXT,
    "quantityOnHand" INTEGER NOT NULL DEFAULT 0,
    "reorderPoint" INTEGER NOT NULL DEFAULT 0,
    "unitCost" DECIMAL NOT NULL DEFAULT 0,
    "unitPrice" DECIMAL NOT NULL DEFAULT 0
);
INSERT INTO InventoryItem VALUES(4,1760793282186,1760793282186,'Engine Oil','OIL-5W30','Synthetic engine oil 5W-30',120,50,25,45);
INSERT INTO InventoryItem VALUES(5,1760793282186,1760793282186,'Brake Pads','BRK-PAD-01','Ceramic brake pads set',30,10,40,85);
CREATE TABLE IF NOT EXISTS "ServiceItem" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "defaultPrice" DECIMAL NOT NULL DEFAULT 0
);
INSERT INTO ServiceItem VALUES(4,1760793282198,1760793282198,'Brake Inspection Labour','Labour charge for full brake inspection',200);
CREATE TABLE IF NOT EXISTS "WorkOrderLog" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "timestamp" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "workOrderId" INTEGER NOT NULL,
    "message" TEXT NOT NULL,
    "author" TEXT,
    "category" TEXT,
    CONSTRAINT "WorkOrderLog_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES "WorkOrder" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO WorkOrderLog VALUES(4,1760793282239,3,'Work order created','system','SYSTEM');
INSERT INTO WorkOrderLog VALUES(5,1760793282239,3,'Vehicle checked into the garage','John Technician','PROGRESS');
INSERT INTO WorkOrderLog VALUES(6,1760793942115,3,'Work order marked as completed','system','SYSTEM');
CREATE TABLE IF NOT EXISTS "WorkOrderAssignment" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "workOrderId" INTEGER NOT NULL,
    "workerId" INTEGER NOT NULL,
    "role" TEXT,
    "notes" TEXT,
    "servicesCount" INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT "WorkOrderAssignment_workOrderId_fkey" FOREIGN KEY ("workOrderId") REFERENCES "WorkOrder" ("id") ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT "WorkOrderAssignment_workerId_fkey" FOREIGN KEY ("workerId") REFERENCES "Worker" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO WorkOrderAssignment VALUES(2,1760793282239,1760793282239,3,1,'Lead Technician',NULL,3);
CREATE TABLE IF NOT EXISTS "Worker" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT,
    "phone" TEXT,
    "commuteExpense" DECIMAL NOT NULL DEFAULT 0,
    "shiftExpense" DECIMAL NOT NULL DEFAULT 0,
    "mealExpense" DECIMAL NOT NULL DEFAULT 0,
    "otherExpense" DECIMAL NOT NULL DEFAULT 0,
    "totalJobs" INTEGER NOT NULL DEFAULT 0,
    "totalServices" INTEGER NOT NULL DEFAULT 0
);
INSERT INTO Worker VALUES(1,1760793282206,1760793282253,'Alex Johnson','alex.johnson@example.com','555-0333',18.5,120,35,12.75,1,3);
DELETE FROM sqlite_sequence;
INSERT INTO sqlite_sequence VALUES('InventoryItem',5);
INSERT INTO sqlite_sequence VALUES('ServiceItem',4);
INSERT INTO sqlite_sequence VALUES('Customer',5);
INSERT INTO sqlite_sequence VALUES('Vehicle',5);
INSERT INTO sqlite_sequence VALUES('WorkOrder',3);
INSERT INTO sqlite_sequence VALUES('WorkOrderLog',6);
INSERT INTO sqlite_sequence VALUES('WorkOrderAssignment',2);
INSERT INTO sqlite_sequence VALUES('WorkOrderLineItem',9);
INSERT INTO sqlite_sequence VALUES('Worker',1);
CREATE UNIQUE INDEX "Customer_email_key" ON "Customer"("email");
CREATE UNIQUE INDEX "Vehicle_vin_key" ON "Vehicle"("vin");
CREATE UNIQUE INDEX "WorkOrder_code_key" ON "WorkOrder"("code");
CREATE UNIQUE INDEX "InventoryItem_sku_key" ON "InventoryItem"("sku");
CREATE UNIQUE INDEX "ServiceItem_name_key" ON "ServiceItem"("name");
CREATE UNIQUE INDEX "WorkOrderAssignment_workOrderId_workerId_key" ON "WorkOrderAssignment"("workOrderId", "workerId");
COMMIT;
