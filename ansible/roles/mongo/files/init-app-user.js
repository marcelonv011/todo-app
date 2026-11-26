const appDb = db.getSiblingDB("todo-app");

if (!appDb.getUser(process.env.MONGO_APP_USERNAME)) {
  appDb.createUser({
    user: process.env.MONGO_APP_USERNAME,
    pwd: process.env.MONGO_APP_PASSWORD,
    roles: [
      {
        role: "readWrite",
        db: "todo-app"
      }
    ]
  });

  print("Usuario de la aplicacion creado correctamente");
}
