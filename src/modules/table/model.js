import { fetch, fetchAll } from '../../lib/postgres.js'

const TABLE = ` 
  SELECT
    DISTINCT ON(t.table_id)
    t.table_id,
    t.table_number,
    CASE
      WHEN o.order_paid = TRUE THEN FALSE
      ELSE TRUE
    END AS table_busy
  FROM tables t
  INNER JOIN (
    SELECT
      *
    FROM orders
    ORDER BY order_created_at DESC
  ) AS o ON o.table_id = t.table_id
  ORDER BY t.table_id
`
const ORDER = ` 
  SELECT 
    o.order_id,
    o.order_created_at,
    t.table_number,
    o.order_id,
    o.order_paid,
    sum(os.price) as order_total_price,
    json_agg(os) order_sets
      FROM orders o 
      NATURAL JOIN tables t
      INNER JOIN (
        SELECT
          os.order_set_id,
          os.count, 
          os.order_id,
          os.order_set_price*os.count price,
          row_to_json(s) steak
        FROM order_sets os
        NATURAL JOIN steaks s 
        GROUP BY os.order_set_id,s.*
  ) os ON os.order_id = o.order_id
  WHERE t.table_id = $1
  GROUP BY o.order_id,t.table_number
  ORDER BY order_created_at DESC;
`

const INSERT_TABLE = `
    delet
`

const DELETE_TABLE = `
    delete from table
    where steak_id = $1
`

const insertTable = ({tableNumber}) => {
  try {
      console.log(tableNumber);
      return fetch(`insert into tables (table_number) values ($1)`, tableNumber)
  } catch(error) {
      throw error
  }
}

const deleteTable = ({tableId}) => {
  try {
      return fetch(`delete from table where table_id = $1 `, tableId)
  } catch(error) {
      throw error
  }
}

const tables = async () => {
  try {
    return await fetchAll(TABLE)
  } catch(error) {
    throw error
  }
}

const order = (tableId = 0) => {
  try {
    return fetch(ORDER, tableId)
  } catch(error) {
    throw error
  }
}

export default {
    tables,
    order,
    insertTable,
    deleteTable
}