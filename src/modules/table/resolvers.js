import model from './model.js'

export default {
    Query: {
        tables: async () => await model.tables()
    },

    Mutation: {
        insertTable: async (_,args) => {
            console.log(args);
            try {
                let table = await model.insertTable(args)
                if (table) {
                    return {
                        status: 201,
                        message: "The order has been updated !!!",
                        data: table
                    }
                } else throw new Error("There is an error !")
            } catch (error) {
                return {
                    status: 400,
                    message: error,
                    data: null
                }
            }
        }
    },

    Table: {
        tableId:     global => global.table_id,
        tableNumber: global => global.table_number,
        tableBusy:   global => global.table_busy,
        order:       async global => {
            if(global.table_busy) return await model.order(global.table_id)
            else return null
        },
        orderCreatedAt: global => global.order_created_at,
        tableId: global => global.table_id,
        orderPaid: global => global.order_paid,
        orderId: global => global.order_id
    }
}