import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class PostgreSQLJDBC {
   public static void main(String args[]) {
      Connection c = null;
      Statement stmt = null;
      try {
         Class.forName("org.postgresql.Driver");
         c = DriverManager
            .getConnection("jdbc:postgresql://localhost:5432/testdb",
            "postgres", "postgres");
         c.setAutoCommit(false);
         System.out.println("Opened database successfully");

         stmt = c.createStatement();
         String sql = "CREATE TABLE student " +
            "(student_id   varchar(50) PRIMARY KEY," +
            " name         varchar(50))";
         stmt.executeUpdate(sql);

         stmt = c.createStatement();
         sql = "CREATE TABLE course " +
            "(course_id    varchar(50) PRIMARY KEY," +
            " name         varchar(50))";
         stmt.executeUpdate(sql);

         stmt = c.createStatement();
         sql = "CREATE TABLE teacher " +
            "(teacher_id   varchar(50) PRIMARY KEY," +
            " name         varchar(50))";
         stmt.executeUpdate(sql);

         stmt = c.createStatement();
         sql = "CREATE TABLE registers " +
            "(student_id varchar(50) REFERENCES student(student_id) ON DELETE CASCADE," +
            " course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE," +
            " PRIMARY KEY (student_id, course_id))";
         stmt.executeUpdate(sql);

         stmt = c.createStatement();
         sql = "CREATE TABLE teaches " +
            "(course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE," +
            " teacher_id varchar(50) REFERENCES teacher(teacher_id) ON DELETE CASCADE," +
            " PRIMARY KEY (teacher_id, course_id))";
         stmt.executeUpdate(sql);

         stmt = c.createStatement();
         sql = "CREATE TABLE section " +
            "(section_number varchar(1) CHECK (section_number IN ('A','B','C','D'))," +
            " course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE," +
            " PRIMARY KEY (course_id, section_number))";
         stmt.executeUpdate(sql);
         
         // stmt = c.createStatement();
         // sql = "INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) "
         //    + "VALUES (1, 'Paul', 32, 'California', 20000.00 );";
         // stmt.executeUpdate(sql);

         // sql = "INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) "
         //    + "VALUES (2, 'Allen', 25, 'Texas', 15000.00 );";
         // stmt.executeUpdate(sql);

         // sql = "INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) "
         //    + "VALUES (3, 'Teddy', 23, 'Norway', 20000.00 );";
         // stmt.executeUpdate(sql);

         // sql = "INSERT INTO COMPANY (ID,NAME,AGE,ADDRESS,SALARY) "
         //    + "VALUES (4, 'Mark', 25, 'Rich-Mond ', 65000.00 );";
         // stmt.executeUpdate(sql);

         stmt.close();
         c.commit();
         c.close();
      } catch (Exception e) {
         System.err.println( e.getClass().getName()+": "+ e.getMessage() );
         System.exit(0);
      }
      System.out.println("Records created successfully");
   }
}