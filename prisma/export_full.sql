USE `gms_db`;

SET FOREIGN_KEY_CHECKS = 0;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;

-- ======================================================
-- 2. CREATE TABLES (dependency order)
-- ======================================================
CREATE TABLE IF NOT EXISTS `Customer` (
  `id`           INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`    DATETIME NOT NULL,
  `firstName`    VARCHAR(255) NOT NULL,
  `lastName`     VARCHAR(255) NOT NULL,
  `email`        VARCHAR(255),
  `phone`        VARCHAR(50) NOT NULL,
  `company`      VARCHAR(255),
  `notes`        TEXT,
  `addressLine1` VARCHAR(255),
  `addressLine2` VARCHAR(255),
  `city`         VARCHAR(100),
  `state`        VARCHAR(100),
  `postalCode`   VARCHAR(20),
  UNIQUE KEY `Customer_email_key` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `Vehicle` (
  `id`           INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`    DATETIME NOT NULL,
  `customerId`   INT NOT NULL,
  `vin`          VARCHAR(17) NOT NULL,
  `make`         VARCHAR(100) NOT NULL,
  `model`        VARCHAR(100) NOT NULL,
  `year`         INT NOT NULL,
  `licensePlate` VARCHAR(20),
  `mileage`      INT,
  `color`        VARCHAR(50),
  `engine`       VARCHAR(100),
  `notes`        TEXT,
  UNIQUE KEY `Vehicle_vin_key` (`vin`),
  CONSTRAINT `Vehicle_customerId_fkey`
    FOREIGN KEY (`customerId`) REFERENCES `Customer` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `WorkOrder` (
  `id`            INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`     DATETIME NOT NULL,
  `code`          VARCHAR(50) NOT NULL,
  `customerId`    INT,
  `vehicleId`     INT NOT NULL,
  `status`        VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  `description`   TEXT NOT NULL,
  `scheduledDate` DATETIME,
  `completedDate` DATETIME,
  `laborCost`     DECIMAL(10,2) NOT NULL DEFAULT 0,
  `partsCost`     DECIMAL(10,2) NOT NULL DEFAULT 0,
  `taxes`         DECIMAL(10,2) NOT NULL DEFAULT 0,
  `discount`      DECIMAL(10,2) NOT NULL DEFAULT 0,
  `totalCost`     DECIMAL(10,2) NOT NULL DEFAULT 0,
  `notes`         TEXT,
  `parkingCharge` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `arrivalDate`   DATETIME,
  `quotedAt`      DATETIME,
  `isHistorical`  TINYINT(1) NOT NULL DEFAULT 0,
  UNIQUE KEY `WorkOrder_code_key` (`code`),
  CONSTRAINT `WorkOrder_customerId_fkey`
    FOREIGN KEY (`customerId`) REFERENCES `Customer` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `WorkOrder_vehicleId_fkey`
    FOREIGN KEY (`vehicleId`) REFERENCES `Vehicle` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `InventoryItem` (
  `id`             INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`      DATETIME NOT NULL,
  `name`           VARCHAR(255) NOT NULL,
  `sku`            VARCHAR(100) NOT NULL,
  `description`    TEXT,
  `quantityOnHand` INT NOT NULL DEFAULT 0,
  `reorderPoint`   INT NOT NULL DEFAULT 0,
  `unitCost`       DECIMAL(10,2) NOT NULL DEFAULT 0,
  `unitPrice`      DECIMAL(10,2) NOT NULL DEFAULT 0,
  UNIQUE KEY `InventoryItem_sku_key` (`sku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `ServiceItem` (
  `id`            INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`     DATETIME NOT NULL,
  `name`          VARCHAR(255) NOT NULL,
  `description`   TEXT,
  `defaultPrice`  DECIMAL(10,2) NOT NULL DEFAULT 0,
  UNIQUE KEY `ServiceItem_name_key` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `WorkOrderLineItem` (
  `id`               INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `workOrderId`      INT NOT NULL,
  `inventoryItemId`  INT,
  `serviceItemId`    INT,
  `description`      TEXT NOT NULL,
  `quantity`         INT NOT NULL DEFAULT 1,
  `unitPrice`        DECIMAL(10,2) NOT NULL DEFAULT 0,
  `lineTotal`        DECIMAL(10,2) NOT NULL DEFAULT 0,
  CONSTRAINT `WorkOrderLineItem_workOrderId_fkey`
    FOREIGN KEY (`workOrderId`) REFERENCES `WorkOrder` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `WorkOrderLineItem_inventoryItemId_fkey`
    FOREIGN KEY (`inventoryItemId`) REFERENCES `InventoryItem` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `WorkOrderLineItem_serviceItemId_fkey`
    FOREIGN KEY (`serviceItemId`) REFERENCES `ServiceItem` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `Worker` (
  `id`             INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`      DATETIME NOT NULL,
  `name`           VARCHAR(255) NOT NULL,
  `email`          VARCHAR(255),
  `phone`          VARCHAR(50),
  `commuteExpense` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `shiftExpense`   DECIMAL(10,2) NOT NULL DEFAULT 0,
  `mealExpense`    DECIMAL(10,2) NOT NULL DEFAULT 0,
  `otherExpense`   DECIMAL(10,2) NOT NULL DEFAULT 0,
  `totalJobs`      INT NOT NULL DEFAULT 0,
  `totalServices`  INT NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `WorkOrderAssignment` (
  `id`          INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `createdAt`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt`   DATETIME NOT NULL,
  `workOrderId` INT NOT NULL,
  `workerId`    INT NOT NULL,
  `role`        VARCHAR(100),
  `notes`       TEXT,
  `servicesCount` INT NOT NULL DEFAULT 0,
  UNIQUE KEY `WorkOrderAssignment_workOrderId_workerId_key` (`workOrderId`,`workerId`),
  CONSTRAINT `WorkOrderAssignment_workOrderId_fkey`
    FOREIGN KEY (`workOrderId`) REFERENCES `WorkOrder` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `WorkOrderAssignment_workerId_fkey`
    FOREIGN KEY (`workerId`) REFERENCES `Worker` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `WorkOrderLog` (
  `id`          INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `timestamp`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `workOrderId` INT NOT NULL,
  `message`     TEXT NOT NULL,
  `author`      VARCHAR(255),
  `category`    VARCHAR(100),
  CONSTRAINT `WorkOrderLog_workOrderId_fkey`
    FOREIGN KEY (`workOrderId`) REFERENCES `WorkOrder` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ======================================================
-- 4. RESTORE ORIGINAL AUTO_INCREMENT VALUES
-- ======================================================
ALTER TABLE `Customer`           AUTO_INCREMENT = 6;
ALTER TABLE `Vehicle`            AUTO_INCREMENT = 6;
ALTER TABLE `WorkOrder`          AUTO_INCREMENT = 4;
ALTER TABLE `WorkOrderLineItem`  AUTO_INCREMENT = 10;
ALTER TABLE `InventoryItem`      AUTO_INCREMENT = 6;
ALTER TABLE `ServiceItem`        AUTO_INCREMENT = 5;
ALTER TABLE `WorkOrderLog`       AUTO_INCREMENT = 7;
ALTER TABLE `WorkOrderAssignment`AUTO_INCREMENT = 3;
ALTER TABLE `Worker`             AUTO_INCREMENT = 2;

-- ======================================================
-- 5. COMMIT
-- ======================================================
SET FOREIGN_KEY_CHECKS = 1;
COMMIT;