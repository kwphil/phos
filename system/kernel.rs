mod lib::lib64::thread::thread

fn boot64( mut system_table: SystemTable ) {
    /* Create a new thread for each device with a driver */
    for i in 0 .. system_table.devices {
        let curr_device = system_table.devices.get(i);

        if curr_device.name.is_empty() {
            kernel64_error("Failed to get device: %d", i, SystemTable.Status.failure.fatal);
        }

        thread::Fork(curr_device.driver.size_req, curr_device.driver.func as *());
    }
}