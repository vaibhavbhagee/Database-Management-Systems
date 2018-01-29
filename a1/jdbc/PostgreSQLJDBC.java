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
         String sql = "DELETE FROM registers;" +
                     "DELETE FROM section;" +
                     "DELETE FROM teaches;" +
                     "DELETE FROM teacher;" +
                     "DELETE FROM student;" +
                     "DELETE FROM course;" +
                     "DROP TABLE registers;" +
                     "DROP TABLE section;" +
                     "DROP TABLE teaches;" +
                     "DROP TABLE teacher;" +
                     "DROP TABLE student;" +
                     "DROP TABLE course;";
         stmt.executeUpdate(sql);

         sql = "CREATE TABLE student " +
            "(student_id   varchar(50) PRIMARY KEY," +
            " name         varchar(50))";
         stmt.executeUpdate(sql);

         sql = "CREATE TABLE course " +
            "(course_id    varchar(50) PRIMARY KEY," +
            " name         varchar(50))";
         stmt.executeUpdate(sql);

         sql = "CREATE TABLE teacher " +
            "(teacher_id   varchar(50) PRIMARY KEY," +
            " name         varchar(50))";
         stmt.executeUpdate(sql);

         sql = "CREATE TABLE registers " +
            "(student_id varchar(50) REFERENCES student(student_id) ON DELETE CASCADE," +
            " course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE," +
            " PRIMARY KEY (student_id, course_id))";
         stmt.executeUpdate(sql);

         sql = "CREATE TABLE teaches " +
            "(course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE," +
            " teacher_id varchar(50) REFERENCES teacher(teacher_id) ON DELETE CASCADE," +
            " PRIMARY KEY (teacher_id, course_id))";
         stmt.executeUpdate(sql);

         sql = "CREATE TABLE section " +
            "(section_number varchar(1) CHECK (section_number IN ('A','B','C','D'))," +
            " course_id varchar(50) REFERENCES course(course_id) ON DELETE CASCADE," +
            " PRIMARY KEY (course_id, section_number))";
         stmt.executeUpdate(sql);

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