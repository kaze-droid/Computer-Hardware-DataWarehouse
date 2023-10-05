/* global use, db */
// MongoDB Playground
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.

const database = 'Accessories';

// The current database to use.
use(database);

// Query 1
use('Accessories');
db.ProductsSold.distinct("Product_ID", {"total_qty_sold": {$eq: 0}})

// Query 2
use('Accessories');
db.ProductsSold.aggregate([ 
    { 
        $lookup: {
             from: "ProductsStock",
             localField: "Product_ID", 
             foreignField: "Product_ID",
             as:"ProductStock"
        }
    },
    {
        $unwind: {
            path: "$ProductStock",
            preserveNullAndEmptyArrays: true
        }
    },
    {
        $group: {
            _id: "$Product_ID",
            Name: 
            {$first: "$ProductStock.Product_Name"},
            total_qty_sold: 
            {$sum: "$total_qty_sold"}, 
            totalStock: 
            {$sum: "$ProductStock.Quantity"}
        }
    },
    {
        $match: {
            total_qty_sold:0
        }
    },
    {
        $sort: {
            totalStock:-1
            }
    },
    {
        $project: {
            _id: 0,
            Product_Name: "$Name",
            Product_ID: "$_id",
            Total_Qty_Sold: "$total_qty_sold",
            Total_Stock: "$totalStock"
        }
    }
])

// Query 3
use('Accessories');
db.ProductsStock.aggregate([
    {
      $group: {
        _id: { CountryName: "$Country_Name", WarehouseName: "$Warehouse_Name"},
      },
    },
    {
      $project: {
        _id: 0,
        CountryName: "$_id.CountryName",
        WarehouseName: "$_id.WarehouseName"
      }
    }
])

// Query 4
use('Accessories');
db.ProductsStock.aggregate([
    {
        $group: {
            _id: "$Warehouse_Name", 
            Product: {$addToSet: "$Product_ID"}
        }
    }, 
    {
        $project: {
            _id: 0, 
            WarehouseName: "$_id", 
            NumOfProducts: {$size: "$Product"}
        }
    }
])




















































