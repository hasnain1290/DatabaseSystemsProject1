package com.group7.lil.jdbc;

import java.sql.*;
import java.util.List;

public abstract class DataAccessObject <T extends DataTransferObject>{
    protected final Connection con;
    protected final static String LAST_VAL = "SELECT last_val FROM";
    
    public DataAccessObject(Connection con) {
        super();
        this.con = con;
    }
    
    public abstract T findById(long id);
    public abstract List<T> findAll();
    public abstract T update(T dto);
    public abstract T create(T dto);
    public abstract void delete(long id);
    
    protected int getLastValue(String sequence) {
        int key = 0;
        String sql = LAST_VAL + sequence;
        try {
            Statement statement = con.createStatement();
            ResultSet rs = statement.executeQuery(sql);
            while(rs.next()) {
                key = rs.getInt(1);
            }
            return key;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException(e);
        }
    }
}
