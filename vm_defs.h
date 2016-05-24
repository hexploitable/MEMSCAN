/*
@Author:  Grant Douglas <@Hexploitable>
@Title:   MEMSCAN
@Desc:    A tool for memory analysis of iOS and OSX applications
@Vers:    1.0.1

@vm_defs.h: Definitions for vm_* APIs
*/

#include <mach/mach.h>
#include "/usr/include/mach/mach_vm.h"
#include <mach/vm_map.h>
#include <mach/vm_region.h>

#ifdef __arm64__
     #define new_vm_read mach_vm_read
     #define new_vm_region mach_vm_region
     #define new_vm_address_t mach_vm_address_t
#else
     #define new_vm_read vm_read
     #define new_vm_region vm_region
     #define new_vm_address_t vm_address_t
#endif

extern kern_return_t mach_vm_read
(
       vm_map_t target_task,
       new_vm_address_t address,
       mach_vm_size_t size,
       vm_offset_t *data,
       mach_msg_type_number_t *dataCnt
);
extern kern_return_t mach_vm_region(vm_map_t,
  new_vm_address_t *,
  mach_vm_size_t *,
  vm_region_flavor_t,
  vm_region_info_t,
  mach_msg_type_number_t *,
  mach_port_t *
);
extern kern_return_t vm_read(
    vm_map_t target_task,
    new_vm_address_t address,
    mach_vm_size_t size,
    Size data_out,
    mach_vm_size_t data_count
);
extern kern_return_t vm_region
(
    vm_map_t target_task,
    new_vm_address_t *address,
    mach_vm_size_t *size,
    vm_region_flavor_t flavor,
    vm_region_info_t info,
    mach_msg_type_number_t *infoCnt,
    mach_port_t *object_name
);
