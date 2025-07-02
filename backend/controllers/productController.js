const { poolPromise, sql } = require('../config/db');

exports.getAllProducts = async (req, res) => {
  try {
    const { search = '', sort = 'PRODUCTID', page = 1 } = req.query;
    const offset = (page - 1) * 10; // Assuming 10 products per page
    const pool = await poolPromise;
const result = await pool
      .request()
      .input('search', sql.NVarChar, `%${search}%`)
      .input('offset', sql.Int, offset)
      .query(`
        SELECT * FROM PRODUCTS
        WHERE PRODUCTNAME LIKE @search
        ORDER BY ${sort} 
        OFFSET @offset ROWS FETCH NEXT 10 ROWS ONLY
      `);    res.status(200).json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.getProductById = async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    const pool = await poolPromise;
    const result = await pool
      .request()
      .input('id', sql.Int, id)
      .query('SELECT * FROM PRODUCTS WHERE PRODUCTID = @id');

    if (result.recordset.length === 0)
      return res.status(404).json({ message: 'Product not found' });

    res.status(200).json(result.recordset[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.createProduct = async (req, res) => {
  const { productName, price, stock } = req.body;

  if (!productName || price <= 0 || stock < 0)
    return res.status(400).json({ message: 'Invalid input' });

  try {
    const pool = await poolPromise;
    await pool
      .request()
      .input('productName', sql.NVarChar(100), productName)
      .input('price', sql.Decimal(10, 2), price)
      .input('stock', sql.Int, stock)
      .query(
        'INSERT INTO PRODUCTS (PRODUCTNAME, PRICE, STOCK) VALUES (@productName, @price, @stock)'
      );

    res.status(201).json({ message: 'Product created' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.updateProduct = async (req, res) => {
  const id = parseInt(req.params.id);
  const { productName, price, stock } = req.body;

  if (!productName || price <= 0 || stock < 0)
    return res.status(400).json({ message: 'Invalid input' });

  try {
    const pool = await poolPromise;
    const result = await pool
      .request()
      .input('id', sql.Int, id)
      .input('productName', sql.NVarChar(100), productName)
      .input('price', sql.Decimal(10, 2), price)
      .input('stock', sql.Int, stock)
      .query(
        'UPDATE PRODUCTS SET PRODUCTNAME = @productName, PRICE = @price, STOCK = @stock WHERE PRODUCTID = @id'
      );

    if (result.rowsAffected[0] === 0)
      return res.status(404).json({ message: 'Product not found' });

    res.status(200).json({ message: 'Product updated' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};

exports.deleteProduct = async (req, res) => {
  const id = parseInt(req.params.id);
  try {
    const pool = await poolPromise;
    const result = await pool
      .request()
      .input('id', sql.Int, id)
      .query('DELETE FROM PRODUCTS WHERE PRODUCTID = @id');

    if (result.rowsAffected[0] === 0)
      return res.status(404).json({ message: 'Product not found' });

    res.status(200).json({ message: 'Product deleted' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
};
