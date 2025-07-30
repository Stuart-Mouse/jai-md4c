/*
    NOTE:
        I had to do a couple little workarounds in the original source code in order
        to be able to properly build the static and dynamic libs from source here.
        Specifically:
            1. including all files from a single `all.c` file
            2. adding `declspec(dllexport)` to the public interface functions (md_parse, md_html, entity_lookup)
                - maybe this needs to be different if someone is not building on Windows
            
        Maybe I didn't really *need* to do it this way but I am a little retarded and this was the most straightforward solution.
        The first workaround was done just so that both md4c and md4c-html get compiled into a single lib instead of 2 separate libs.
        This was causing me issues with linking when it came time to actually build the main program, 
            since md4c-html itself needs to be linked against md4c or something.
        
*/

AT_COMPILE_TIME :: true;

SOURCE_PATH :: "source";

INCLUDE_FILES :: string.[
    "md4c.h", 
    "md4c-html.h", 
    "entity.h", 
];

#if AT_COMPILE_TIME {
    #run,stallable {
        set_build_options_dc(.{do_output=false});
        options := get_build_options();
        args := options.compile_time_command_line;
        if !generate_bindings(args, options.minimum_os_version) {
            compiler_set_workspace_status(.FAILED);
        }
    }
} else {
    #import "System";

    main :: () {
        set_working_directory(path_strip_filename(get_path_of_running_executable()));
        if !generate_bindings(get_command_line_arguments(), #run get_build_options().minimum_os_version) {
            exit(1);
        }
    }
}

generate_bindings :: (args: [] string, minimum_os_version: type_of(Build_Options.minimum_os_version)) -> bool {
    os_target  := OS;
    cpu_target := CPU;
    
    compile        := array_find(args, "-compile");
    compile_debug  := array_find(args, "-debug");
    
    lib_directory: string;
    if os_target == {
        case .WINDOWS;
            lib_directory = "windows";
        case .LINUX;
            lib_directory = "linux";
        case;
            assert(false);
    }
    
    if compile {
        success := true;
        {
            source_file := tprint("%/all.c", SOURCE_PATH);
            make_directory_if_it_does_not_exist(lib_directory, recursive = true);
            lib_path := tprint("%/%", lib_directory, "md4c");
            success &&= build_cpp_dynamic_lib(lib_path, source_file, target = os_target, debug = compile_debug);
            success &&= build_cpp_static_lib (lib_path, source_file, target = os_target, debug = compile_debug);
        }
        if !success     return false;
    }
    
    options: Generate_Bindings_Options;
    options.os = os_target;
    options.cpu = cpu_target;
    {
        using options;
        
        array_add(*library_search_paths, lib_directory);
        array_add(*libraries, .{ filename = "md4c" });
        
        for INCLUDE_FILES array_add(*source_files, tprint("%/%", SOURCE_PATH, it));
        
        auto_detect_enum_prefixes = true;
        log_stripped_declarations = true;
        generate_compile_time_struct_checks = false;
    }

    output_filename := "bindings.jai";
    return generate_bindings(options, output_filename);
}

#import "Basic";
#import "BuildCpp";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
