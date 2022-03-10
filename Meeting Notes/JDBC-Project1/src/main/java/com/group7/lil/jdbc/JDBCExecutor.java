package com.group7.lil.jdbc;

import java.sql.*;

public class JDBCExecutor {

    public static void main(String[] args) {
        // TODO Auto-generated method stub
        DatabaseConnectionManager dcm = new DatabaseConnectionManager("localhost", "12001", "Northwinds2020TSQLV6", "sa", "PH@123456789");
        try {
            Connection connection = dcm.getConnection();
            Statement statement = connection.createStatement();
            ResultSet resultSet = statement.executeQuery("Select OrderId, CustomerId From Sales.[Order]");
            while (resultSet.next()) {
                System.out.println(resultSet.getString("OrderId") + " " + resultSet.getString("CustomerId"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

}
