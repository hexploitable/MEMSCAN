/*
@Author:  Grant Douglas <@Hexploitable>
@Title:   MEMSCAN
@Desc:    A tool for memory analysis of iOS and OSX applications
@Vers:    1.0.1

@vm_defs.h: Definitions for vm_* APIs
*/

extern kern_return_t vm_region
(
     vm_map_t target_task,
     mach_vm_address_t *address,
     mach_vm_size_t *size,
     vm_region_flavor_t flavor,
     vm_region_info_t info,
     mach_msg_type_number_t *infoCnt,
     mach_port_t *object_name
 );

extern kern_return_t vm_read
(
     vm_map_t target_task,
     mach_vm_address_t address,
     mach_vm_size_t size,
     Size data_out,
     mach_vm_size_t data_count
 );

extern kern_return_t vm_read_overwrite
(
     vm_map_t target_task,
     mach_vm_address_t address,
     mach_vm_size_t size,
     mach_vm_address_t data,
     mach_vm_size_t *outsize
 );
