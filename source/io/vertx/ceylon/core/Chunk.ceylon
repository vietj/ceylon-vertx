import org.vertx.java.core.buffer {
  Buffer
}

"""A chunk of data, it can be:
   
   * A mere string
   * A string plus an encoding
   * A buffer 
   """
shared alias Chunk => String|[String,String]|Buffer;