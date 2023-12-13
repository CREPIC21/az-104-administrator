// Access command-line arguments in Node.js
const connectionString = process.argv[2]; // Assuming $c is passed as the first argument

const { TableClient } = require('@azure/data-tables');
const tableName = "VisitorCount";
async function main() {
    const serviceClient = TableClient.fromConnectionString(connectionString, tableName);

    try {
        // Create table
        await serviceClient.createTable(tableName);
        console.log("Table created successfully");

        // Entity to add
        const entity = {
            partitionKey: "Counts",
            rowKey: "VisitorCount",
            /* Add other properties as needed */
            count: 0 // Sample property: count with value 0
        };

        // Add the entity to the table
        await serviceClient.createEntity(entity);
        console.log("Entity added successfully");
    } catch (error) {
        console.error("Error:", error);
    }
}

main();
