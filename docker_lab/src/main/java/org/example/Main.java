package org.example;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.Statement;

public class Main {

    private static final String DB_URL = "jdbc:postgresql://db:5432/app_db";
    private static final String USER = "postgres";
    private static final String PASSWORD = "example";

    public static void main(String[] args) {
        try (Connection connection = DriverManager.getConnection(DB_URL, USER, PASSWORD)) {
            System.out.println("Connected!");

            String createTableSQL = """
                                    CREATE TABLE IF NOT EXISTS cars (
                                        id SERIAL PRIMARY KEY,
                                        name VARCHAR(100) NOT NULL)
                                    """;
            try (Statement statement = connection.createStatement()) {
                statement.execute(createTableSQL);
                System.out.println("Created table!");
            }

            String insertSQL = "INSERT INTO cars (name) VALUES (?)";
            try (PreparedStatement preparedStatement = connection.prepareStatement(insertSQL)) {
                preparedStatement.setString(1, "BMW");
                preparedStatement.executeUpdate();
                preparedStatement.setString(1, "Audio");
                preparedStatement.executeUpdate();
                System.out.println("Added cars!");
            }

        } catch (Exception ignore) {}
    }
}