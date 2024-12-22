namespace School.Models.ZatcaModels
{
    public class InvoiceProcessor
    {

        public static string Populate(ZATCASimplifiedInvoiceProps props, string template)
        {
            string populated_template = template;

            populated_template = populated_template.Replace("SET_INVOICE_TYPE", props.cancelation != null ? props.cancelation.cancelation_type.ToString() : ZATCAInvoiceTypes.INVOICE.ToString());
            // if canceled (BR-KSA-56) set reference number to canceled invoice
            if (props.cancelation != null)
            {
                //populated_template = populated_template.Replace("SET_BILLING_REFERENCE", DefaultBillingReference(populated_template, props.cancelation.canceled_invoice_number));
                populated_template = populated_template.Replace("SET_BILLING_REFERENCE", props.cancelation.canceled_invoice_number.ToString());
            }
            else
            {
                populated_template = populated_template.Replace("SET_BILLING_REFERENCE", "");
            }

            populated_template = populated_template.Replace("SET_INVOICE_SERIAL_NUMBER", props.invoice_serial_number);
            populated_template = populated_template.Replace("SET_TERMINAL_UUID", props.egs_info.uuid);
            populated_template = populated_template.Replace("SET_ISSUE_DATE", props.issue_date);
            populated_template = populated_template.Replace("SET_ISSUE_TIME", props.issue_time);
            populated_template = populated_template.Replace("SET_PREVIOUS_INVOICE_HASH", props.previous_invoice_hash);
            populated_template = populated_template.Replace("SET_INVOICE_COUNTER_NUMBER", props.invoice_counter_number.ToString());
            populated_template = populated_template.Replace("SET_COMMERCIAL_REGISTRATION_NUMBER", props.egs_info.CRN_number);

            populated_template = populated_template.Replace("SET_STREET_NAME", props.egs_info.location.street);
            populated_template = populated_template.Replace("SET_BUILDING_NUMBER", props.egs_info.location.building);
            populated_template = populated_template.Replace("SET_PLOT_IDENTIFICATION", props.egs_info.location.plot_identification);
            populated_template = populated_template.Replace("SET_CITY_SUBDIVISION", props.egs_info.location.city_subdivision);
            populated_template = populated_template.Replace("SET_CITY", props.egs_info.location.city);
            populated_template = populated_template.Replace("SET_POSTAL_NUMBER", props.egs_info.location.postal_zone);

            populated_template = populated_template.Replace("SET_VAT_NUMBER", props.egs_info.VAT_number);
            populated_template = populated_template.Replace("SET_VAT_NAME", props.egs_info.VAT_name);
            return populated_template;
        }

        private static string DefaultBillingReference(string template, int invoiceNumber)
        {
            // Implement the logic to generate the default billing reference
            string populatedTemplate = template;
            populatedTemplate = populatedTemplate.Replace("SET_INVOICE_NUMBER", $"{invoiceNumber}");
            return populatedTemplate;
        }


    }
}
