// Please Play with all these different type of arrays 
// Learn the different possiblities to arrange an array
// Visualize how packed arrays are physically represented in physical memory  


`timescale 1ns/1ns

module diff_arrays;
    reg [2047:0] vcdplusfile;

    //-----------------------------------------
    // Packed arrays and Unpacked arrays
    //-----------------------------------------
    bit [4:0][3:0] arr1 [2:0][1:0];
    bit [4:0][3:0] arr2 [2:0][1:0];
    bit [4:0][3:0] arr3 [], arr4[];
    int temp, cnt = 10;
    integer a_arr0[integer];
    integer a_arr1[string];
    int int_q[$];
    int bounded_intq[$:2];
    int val, size;
    
    initial begin

`ifdef VCS
        if ($value$plusargs("vcdplusfile=%s", vcdplusfile))
        begin
            $vcdplusfile(vcdplusfile);
            $vcdpluson(0);
            $vcdplusmemon(0);
        end
`else
            $fdisplay(stderr, "Error: +vcdplusfile is VCS-only; use +vcdfile instead or recompile with VCS=1");
            $fatal;
`endif

        //-----------------------------------------
        // Packed arrays and Unpacked arrays
        //-----------------------------------------
        temp = 1;
        arr1 = arr2;
        if (arr1 == arr2)
            $display ("Arrays are equal");
        arr1[1][1] = arr2[2][0];
        if (arr1[1][1]!= arr2[2][0])
            $display ("Arrays are not equal");
        arr1[1][1][1][2:1] = arr2[2][0][0][1:0];
        if (arr1[1][1][1][2:1]!= arr2[2][0][0][1:0])
            $display ("Array slices are not equal");
        arr1[1][1][1][temp +:2] = arr2[2][0][0][(temp-1) +:2];

        //-----------------------------------------
        // Dynamic array 
        //-----------------------------------------
        arr3 = new[cnt];
        $display(arr3.size()); // displays 10;
        arr4 = new[20](arr3);
        $display(arr4.size()); // displays 20;
        arr3.delete();
        $display(arr3.size()); // displays 0;
        
        //-----------------------------------------
        // Associative array  
        //-----------------------------------------
        a_arr1["jack"] = 1414;
        a_arr1[""] = 2424;
        a_arr1[34] = 234;
        $display(a_arr1["jack"], a_arr1[""], a_arr1[34]);
        
        
        //-----------------------------------------
        // Queues   
        //-----------------------------------------
        size = int_q.size(); // size=0, int_q={}
        int_q.push_back(10); // int_q={10}
        int_q.push_back(20); // int_q={10,20}
        int_q.push_front(30); // int_q={30,10,20}
        int_q.push_front(40); // int_q={40,30,10,20}
        int_q.insert(1, 50); // int_q={40,50,30,10,20}
        int_q.insert(3, 60); // int_q={40,50,30,60,10,20}
        val = int_q.pop_back(); // val=20, int_q={40,50,30,60,10}
        val = int_q.pop_front(); // val=40, int_q={50,30,60,10}
        int_q.delete(2); // int_q={50,30,10}
        val = int_q[1]; // val = 30
        val = int_q[100]; // val = 0;
        size = int_q.size(); // size = 3
    end
endmodule 