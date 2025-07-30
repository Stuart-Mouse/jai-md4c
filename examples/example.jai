// Because we only get one data pointer for the callback, 
// you may want to create some struct like this 
// so that you can pass a string builder and a context pointer.
String_Builder_And_Context :: struct {
    builder: *String_Builder;
    ctx:     *#Context;
}

main :: () {
    process_output :: (
        chunk: *MD_CHAR,
        chunk_size: MD_SIZE,
        userdata: *void
    ) #c_call {
        using data := userdata.(*String_Builder_And_Context);
        push_context ctx {
            append(builder, string.{ chunk_size, chunk });
        }
    }
    
    builder: String_Builder;
    sb_and_ctx := String_Builder_And_Context.{ *builder, *context };
    result := md_html(TEST_INPUT.data, TEST_INPUT.count, process_output, *sb_and_ctx, 0, 0);
    log("%", builder_to_string(*builder));
}

TEST_INPUT :: #string MD
# Heading 1
## Heading 2
### Heading 3
```c
int main(int argc, char** argv) {
    printf("Hello, World!");
}
```
MD;

#import "Basic";
#import "md4c";