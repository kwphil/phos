#include <efi.h>
#include <efilib.h>

EFI_STATUS
EFIAPI
efi_main (EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable) {
    InitializeLib(ImageHandle, SystemTable);

    Print(L"Booted in UEFI BIOS!");

    EFI_FILE_PROTOCOL *KernelFile;
    EFI_STATUS Status = uefi_call_wrapper(SystemTable->BootServices->OpenProtocol,
                                          6,
                                          ImageHandle,
                                          L"\\boot\\kernel32.bin",
                                          &KernelFile,
                                          ImageHandle,
                                          NULL,
                                          EFI_OPEN_PROTOCOL_BY_HANDLE_PROTOCOL);

    if( EFI_ERROR(Status) ) {
        Print(L"Failes to open kernel file: %r\n", Status);
        return Status;
    }

    UINTN FileInfoSize = sizeof(EFI_FILE_INFO) + 0x1000;
    EFI_FILE_INFO *FileInfo;
    Status = uefi_call_wrapper(SystemTable->BootServices->AllocatePool,
                               3,
                               EfiLoaderData,
                               FileInfoSize,
                               (void **)&FileInfo);

    if(EFI_ERROR,(Status)) {
        Print(L"Failed to allocate memory for file info: %r\n", Status);
        return Status;
    }

    Status = uefi_call_wrapper(SystemTable->BootServices->AllocatePages,
                               4,
                               AllocateAnyPages,
                               EfiLoaderData,
                               (KernelSize + EFI_PAGE_SIZE - 1) / EFI_PAGE_SIZE,
                               &KernelAddress);

    if(EFI_ERROR(Status)) {
        Print(L"Failed to allocate memory for kernel: %r\n", Status);
        return Status;
    }

    Status = uefi_call_wrapper(KernelFile->Read,
                               3,
                               KernelFile,
                               &KernelSize,
                               (void *)KernelAddress);

    if(EFI_ERROR(Status)) {
        Print(L"Failed to read kernel file: %r\n", Status);
        return Status;
    }

    uefi_call_wrapper(KernelFile->Close,
                      1,
                      KernelFile);

    EFI_STATUS (*KernelEntry)(EFI_HANDLE, EFI_SYSTEM_TABLE*);
    KernelEntry = (EFI_STATUS (*) (EFI_HANDLE,
                                   EFI_SYSTEM_TABLE*))KernelAddress;
    Status = KernelEntry(ImageHandle, SystemTable);
    if(EFI_ERROR(Status)) {
        Print(L"Failed to start kernel: %r\n", Status);
        return Status;
    }

    return EFI_SUCCESS;
}