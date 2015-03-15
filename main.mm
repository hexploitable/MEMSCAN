/*
  @Author:  Grant Douglas <@Hexploitable>
  @Title:   MEMSCAN
  @Desc:    A tool for memory analysis of iOS and OSX applications
  @Vers:    1.0.1
*/

//Lib includes
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <dlfcn.h>
#include <mach-o/dyld_images.h>
#include <string.h>
#include <limits.h>
#include <errno.h>

//Local includes
#include "colour_defs.h"
#include "vm_defs.h"
#include "banner.h"


//  "Globals"
static int g_pid = 0;
static unsigned char *nBuffer;
static char *o_File = NULL;
static int pid = 0;
static int needleLen = 0;
static int verbose = 0;


//  Prints the usage of memscan
static void printUsage(void)
{
    printf("Usage:\n-------\n");
    printf("Verbose mode: -v\n");
    printf("Dump memory to a file: memscan [-p <PID>] -d [-o <outputFile>]\n");
    printf("Search memory for a sequence of bytes: memscan [-p <PID>] -s <INPUT_FILE>\n");
}


/*
    Scans a region of memory begining at addr, of size "size"
    shouldPrint == 1 means we're dumping to a file.
    shouldPrint == 0 means we're scanning for an object. 
*/
static new_vm_address_t *scanMem(int pid, new_vm_address_t addr, mach_msg_type_number_t size, int shouldPrint)
{
    #ifdef __arm64__
        vm_offset_t strt = 0;
        mach_msg_type_number_t sz = 0;
    #else
        pointer_t strt;
        uint32_t sz = 0;
    #endif
    //vm_map_t, mach_vm_address_t, mach_vm_size_t, mach_vm_address_t, mach_vm_size_t *

    task_t t;
    task_for_pid(mach_task_self(), pid, &t);
    mach_msg_type_number_t dataCnt = size;
    new_vm_address_t max = addr + size;
    int bytesRead = 0;
    kern_return_t kr_val;
    new_vm_address_t memStart = 0;
    
    FILE *f = fopen(o_File, "w+");

    if (shouldPrint == 1)
    {
        #ifdef __arm64__
            kr_val = new_vm_read(t, addr, size, &strt, &sz);
        #else
            kr_val = new_vm_read(t, addr, size, &strt, &sz);
        #endif

        if (kr_val == KERN_SUCCESS)
        {
        	printf("Size of read: %d\n", sz);
        }
        else
        {
        	  printf("KR: %d\n", kr_val);
        	  printf("Size: %d\n", size);
        }
        fwrite((const void*)strt, size, 1, f);
        fclose(f);
        exit(0);
    }
    else
    {
        unsigned char buffer[needleLen];
        FILE *f = fopen(o_File, "w+");
        while (bytesRead < size)
        {

            #ifdef __arm64__
                kr_val = new_vm_read(t, addr, sizeof(unsigned char), &strt, &sz);
            #else
                kr_val = new_vm_read(t, addr, sizeof(unsigned char), &strt, &sz);
            #endif

            if (kr_val == KERN_SUCCESS)
            {
                memcpy(buffer, (const void *)strt, sz);
                if (memcmp(buffer, nBuffer, needleLen) == 0)
                {
                    fflush(stdout);
                    return (new_vm_address_t *)addr;
                }
                else
                    printf("[%s-%s] %s%p%s ---> mach_vm_read()\r", red, none, redU, addr, none);
                fflush(stdout);
            }
            else
            {
                printf("[%s-%s] %s%p%s ---> mach_vm_read()\r", red, none, redU, addr, none);
                fflush(stdout);
            }
            addr += sizeof(unsigned char);
            bytesRead += sizeof(unsigned char);
        }
        printf("[%si%s] Scanning ended without a match.\r\n", yellow, none);
        fflush(stdout);
    }
    return NULL;
}



/*
    Cycles through the mach regions of the process.
    For each, it executes scanMem.
    If scanning for objects, it returns a ptr.
*/
static unsigned int *getMemRegions(task_t task, new_vm_address_t address, int shouldPrint)
{
    #ifdef __arm64__
        mach_vm_size_t size;
        mach_vm_size_t fullSize = 0;
    #else
        vm_size_t size;
        vm_size_t fullSize = 0;
    #endif
    //vm_map_t, mach_vm_address_t, mach_vm_size_t, mach_vm_address_t, mach_vm_size_t *
    kern_return_t kret;
    vm_region_basic_info_data_t info;
    
    mach_port_t object_name;
    mach_msg_type_number_t count;
    new_vm_address_t firstRegionBegin;
    new_vm_address_t lastRegionEnd;
    
    count = VM_REGION_BASIC_INFO_COUNT_64;
    int regionCount = 0;
    int flag = 0;

    printf("[%si%s] Cycling through memory regions, please wait...\n", yellow, none);

    while (flag == 0)
    {
        char *name = "Region: ";
        char cated_string[17];
        sprintf(cated_string,"%s%d", name, regionCount);
        if (verbose)
        {
            printf("Region: %d\n", regionCount);
        }
        FILE *f = fopen(o_File, "a+");
        fwrite(cated_string, sizeof(cated_string), 1, f);

        //Attempts to get the region info for given task
        //vm_map_t, new_vm_address_t *, mach_vm_size_t *, vm_region_flavor_t, vm_region_info_t, mach_msg_type_number_t *, mach_port_t *
        #ifdef __arm64__
            kret = new_vm_region(task, &address, &size, VM_REGION_BASIC_INFO, (vm_region_info_t) &info, &count, &object_name);
        #else
            kret = new_vm_region(task, &address, &size, VM_REGION_BASIC_INFO, (vm_region_info_t) &info, &count, &object_name);
        #endif
        
        if (kret == KERN_SUCCESS)
        {
            if (regionCount == 0)
            {
                firstRegionBegin = address;
            }
            regionCount += 1;
            if (shouldPrint == 1)
            {
                task_t t;
                task_for_pid(mach_task_self(), pid, &t);
                kern_return_t kr_val;
                #ifdef __arm64__
                    vm_offset_t strt = 0;
                    mach_msg_type_number_t sz = 0;
                #else
                    pointer_t strt;
                    uint32_t sz = 0;
                #endif
                //vm_map_t, mach_vm_address_t, mach_vm_size_t, mach_vm_address_t, mach_vm_size_t *
                

                #ifdef __arm64__
                    kr_val = new_vm_read(t, address, size, &strt, &sz);
                #else
                    kr_val = new_vm_read(t, address, size, &strt, &sz);
                #endif                

                if (kr_val == KERN_SUCCESS)
                {
                    if (verbose)
                        printf("Region start: %p\nSize of read: %d\n\n", address, sz);
                    //memcpy(readbuffer, (const void*)(pointer_t)strt, sz);
                }
                else
                {
                    if (verbose)
                        printf("Region start: %p\nSize of read: %d\n\n", address, sz);
                }
                fwrite((const void*)strt, sz, 1, f);
                if (verbose)
                    printf("[%si%s] Memory dumped: %s\r\n", yellow, none, cated_string);

            }
            fullSize += size;
            address += size;
        }
        else
            flag = 1;
        fclose(f);

    }
    if (shouldPrint == 1)
    {
        printf("[%si%s] Operation Completed.\r\n", blue, none);
        exit(0);
    }
    lastRegionEnd = address;
    printf("[%si%s] Proc Space: %s%p%s - %s%p%s\n", yellow, none, yellowU, firstRegionBegin, none, blueU, lastRegionEnd, none);

    unsigned int *ptrToFunc = (unsigned int *)scanMem(pid, firstRegionBegin, fullSize, shouldPrint);
    return ptrToFunc;
}


//Needs no explanation...
int main(int argc, char** argv) {
    kern_return_t rc;
    mach_port_t task;
    new_vm_address_t addr = 1;

    int shouldDump = 0;
    char *i_File = NULL;

    BANNER
    while (1)
    {
        char c;
        c = getopt(argc, argv, "ds:o:vp:");
        if (c == -1)
            break;
        switch (c)
        {
            case 'd':
                shouldDump = 1;
                break;
            case 's':
                i_File = optarg;
                break;
            case 'p':
                pid = atoi(optarg);
                break;
            case 'v':
                verbose = 1;
                break;
            case 'o':
                o_File = optarg;
                break;
            default:
                printUsage();
                break;
        }
    }

    argc -= optind;
    argv += optind;

    if (shouldDump == 0 && i_File == NULL)
    {
        printUsage();
        exit(-1);
    }

    if (i_File)
    {
        g_pid = pid; //Required for fw >= 6.0
        rc = task_for_pid(mach_task_self(), pid, &task);
        if (rc)
        {
            fprintf(stderr, "[%s-%s] task_for_pid() failed, error %d - %s%s", red, none, rc, red, mach_error_string(rc), none);
            exit(1);
        }

        FILE *f = fopen(i_File, "rb");
        if (f)
        {
            fseek(f, 0, SEEK_END);
            needleLen = ftell(f);
            fclose(f);
        }

        unsigned char buf[needleLen+1];
        FILE *fr;
        fr = fopen(i_File, "rb");
        long int cnt = 0;
        while ((cnt = (long)fread(buf, sizeof(unsigned char), needleLen, fr))>0)
            nBuffer = buf;
        fclose(fr);

        printf("[%s+%s] PID: %s%d%s\n", green, none, blueU, pid, none);
        printf("[%si%s] Task: %s%d%s\n", yellow, none, blueU, task, none);
        printf("[%si%s] Attempting to search for bytes\n", yellow, none);
        printf("[%s+%s] Needle Length: %s%d%s %sbytes%s\n", green, none, blue, needleLen, none, blueU, none);
        unsigned int *sym = getMemRegions(task, addr, 0);
        if (sym != NULL)
            printf("\n\n[%s$%s] Located target function ---> %s%p%s\n\n", cyan, none, cyanU, sym, none);
        else
            printf("[%s-%s] Didn\'t find the function.\n", red, none);
    }
    else if (shouldDump)
    {
        g_pid = pid; //Required for fw >= 6.0
        rc = task_for_pid(mach_task_self(), pid, &task);
        if (rc)
        {
            fprintf(stderr, "[%s-%s] task_for_pid() failed, error %d - %s%s", red, none, rc, red, mach_error_string(rc), none);
            exit(1);
        }

        //If output File already exists.
        if (o_File == NULL)
            o_File = "output.bin";
        else if (access(o_File, F_OK) != -1)
        {
          printf("[i] %s already exists, would you like to overwrite it? Y/(N):\n", o_File);
          char answer[1];
          scanf("%1[^\n]", answer);
          if ((strcmp(answer, "y") == 1) || (strcmp(answer, "Y") ==1))
              printf("[%si%s] Overwriting %s\n", yellow, none, o_File);
          else
              o_File = "output.bin";
        }

        printf("[%si%s] Dump will be written to %s\n", yellow, none, o_File);
        printf("[%s+%s] PID: %s%d%s\n", green, none, blueU, pid, none);
        printf("[%si%s] Task: %s%d%s\n", yellow, none, blueU, task, none);
        printf("[%si%s] Attempting to dump all strings found in memory\n", yellow, none);
        unsigned int *sym = getMemRegions(task, addr, 1);
    }
    else
    {
        printUsage();
        exit(-1);
    }
    return 0;
}
