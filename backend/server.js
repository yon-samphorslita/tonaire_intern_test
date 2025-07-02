const express = require('express');
const cors = require('cors');
require('dotenv').config();

const productRoute = require('./routes/productRoute');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/', productRoute);

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
