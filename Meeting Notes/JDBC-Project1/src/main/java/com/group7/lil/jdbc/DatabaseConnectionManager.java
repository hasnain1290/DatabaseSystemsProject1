package com.group7.lil.jdbc;

import java.sql.*;
import java.util.*;

public class DatabaseConnectionManager {
    private final String url;
    private final Properties properties;
    
    public DatabaseConnectionManager (String host, String port, String databaseName, String username, String password) {
        this.url = "jdbc:sqlserver://" + host + ":" + port + ";databaseName=" + databaseName + ";user=" + username + ";password=" + password;
        this.properties = new Properties();
        this.properties.setProperty("user", username);
        this.properties.setProperty("password", password);
    }
    
    public Connection getConnection () throws SQLException {
        return DriverManager.getConnection(this.url, this.properties);
    }
}
