import { subDays } from "date-fns";

import { prisma } from "../../lib/prisma";

const LOW_STOCK_THRESHOLD = 5;

export const getDashboardSummary = async () => {
  const [
    customers,
    vehicles,
    openWorkOrders,
    completedWorkOrders,
    inventoryItems,
    workers,
  ] = await Promise.all([
    prisma.customer.count(),
    prisma.vehicle.count(),
    prisma.workOrder.count({
      where: {
        status: { in: ["PENDING", "IN_PROGRESS"] },
      },
    }),
    prisma.workOrder.findMany({
      where: {
        status: "COMPLETED",
        updatedAt: {
          gte: subDays(new Date(), 30),
        },
      },
      select: {
        id: true,
        code: true,
        totalCost: true,
        updatedAt: true,
      },
      orderBy: { updatedAt: "desc" },
      take: 10,
    }),
    prisma.inventoryItem.findMany({
      orderBy: { quantityOnHand: "asc" },
    }),
    prisma.worker.findMany({
      orderBy: [
        { totalJobs: "desc" },
        { totalServices: "desc" },
        { name: "asc" },
      ],
      take: 8,
      select: {
        id: true,
        name: true,
        totalJobs: true,
        totalServices: true,
        assignments: {
          orderBy: { createdAt: "desc" },
          take: 1,
          select: {
            createdAt: true,
            workOrder: {
              select: {
                id: true,
                code: true,
                status: true,
              },
            },
          },
        },
      },
    }),
  ]);

  const revenueLast30Days = completedWorkOrders.reduce(
    (sum, order) => sum + order.totalCost.toNumber(),
    0,
  );
  const criticalInventory = inventoryItems.filter(
    (item) => item.quantityOnHand <= LOW_STOCK_THRESHOLD,
  );

  return {
    totals: {
      customers,
      vehicles,
      openWorkOrders,
    },
    revenueLast30Days,
    recentCompletedWorkOrders: completedWorkOrders,
    inventoryAlertsCount: criticalInventory.length,
    lowStockItems: criticalInventory.slice(0, 5),
    topWorkers: workers.map((worker) => ({
      id: worker.id,
      name: worker.name,
      totalJobs: worker.totalJobs,
      totalServices: worker.totalServices,
      lastAssignment: worker.assignments[0]
        ? {
            createdAt: worker.assignments[0].createdAt,
            workOrder: worker.assignments[0].workOrder,
          }
        : null,
    })),
  };
};
