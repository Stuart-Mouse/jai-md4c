
AT_COMPILE_TIME :: true;

SOURCE_PATH :: "source";
// LIB_BASE_NAME :: "md4c";

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
    
    // Can't get this to work at the moment, so whatever...
    // I probably just need to build the entity.c file separately as some obj and then pass that when building md4c-html?
    // if compile {
    //     success := true;
    //     {
    //         source_files := string.[
    //             tprint("%/md4c.c",      SOURCE_PATH),
    //         ];
    //         make_directory_if_it_does_not_exist(lib_directory, recursive = true);
    //         lib_path := tprint("%/%", lib_directory, "md4c");
    //         success &&= build_cpp_dynamic_lib(lib_path, ..source_files, target = os_target, debug = compile_debug);
    //         success &&= build_cpp_static\_lib(lib_path, ..source_files, target = os_target, debug = compile_debug);
            
    //         log("===== BUILDING OBJ ====");
    //         success &&= build_cpp(lib_path, ..source_files, .OBJ_FILE,  target = os_target, debug = compile_debug);
    //         log("===== BUILDING OBJ % ====", ifx success then "SUCCESS" else "FAILED");
    //     }
    //     {
    //         source_files := string.[
    //             tprint("%/md4c-html.c", SOURCE_PATH),
    //             tprint("%/entity.c",    SOURCE_PATH),
    //         ];
    //         make_directory_if_it_does_not_exist(lib_directory, recursive = true);
    //         lib_path := tprint("%/%", lib_directory, "md4c-html");
    //         success &&= build_cpp_dynamic_lib(lib_path, ..source_files, target = os_target, debug = compile_debug, library_files=.["windows/md4c"]);
    //         success &&= build_cpp_static\_lib(lib_path, ..source_files, target = os_target, debug = compile_debug, library_files=.["windows/md4c"]);
    //     }
    //     if !success     return false;
    // }
    
    options: Generate_Bindings_Options;
    options.os = os_target;
    options.cpu = cpu_target;
    {
        using options;
        
        // strip_flags &= ~.SYMBOLS_WITH_UNKNOWN_FOREIGN_LIBS;
        
        array_add(*libpaths, lib_directory);
        array_add(*libnames, "md4c");
        array_add(*libnames, "md4c-html");
        
        // array_add(*include_paths, SOURCE_PATH);
        for INCLUDE_FILES array_add(*source_files, tprint("%/%", SOURCE_PATH, it));
        
        // generate_library_declarations = false;
        // footer = tprint(FOOTER_TEMPLATE, "md4c");

        auto_detect_enum_prefixes = true;
        log_stripped_declarations = true;
        generate_compile_time_struct_checks = false;
    }

    output_filename := "bindings.jai";
    return generate_bindings(options, output_filename);
}

// FOOTER_TEMPLATE :: #string END

// #if OS == .WINDOWS {
//     %1 :: #library "windows/%1";
// } else #if OS == .LINUX {
//     %1 :: #library "linux/%1";
// } else {
//     #assert false;
// }

// END

#import "Basic";
#import "BuildCpp";
#import "Bindings_Generator";
#import "Compiler";
#import "File";
