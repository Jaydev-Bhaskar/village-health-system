const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log(`MongoDB Connected: ${conn.connection.host}`);

    // Fix stale indexes: drop old non-sparse email unique index if it exists
    // This is needed because earlier versions of the User schema had email as required+unique
    // but now email is optional+sparse. MongoDB keeps old indexes unless manually dropped.
    try {
      const User = require('../models/User');
      const indexes = await User.collection.indexes();
      const emailIndex = indexes.find(
        (idx) => idx.key && idx.key.email && idx.unique && !idx.sparse
      );
      if (emailIndex) {
        console.log('Dropping stale non-sparse email index:', emailIndex.name);
        await User.collection.dropIndex(emailIndex.name);
        console.log('Old email index dropped. Mongoose will recreate with sparse: true.');
      }
    } catch (indexErr) {
      // Ignore if index doesn't exist or already correct
      if (indexErr.code !== 27) {
        console.warn('Index cleanup note:', indexErr.message);
      }
    }
  } catch (err) {
    console.error(`MongoDB connection error: ${err.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
