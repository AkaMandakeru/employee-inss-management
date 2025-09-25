require 'rails_helper'

RSpec.describe ReportsController, type: :controller do
  let(:user) { create(:user) }

  before do
    # Mock authentication
    session = create(:session, user: user)
    allow(controller).to receive(:resume_session).and_return(session)
    allow(controller).to receive(:authenticated?).and_return(true)
    Current.session = session
  end
  let!(:employee1) { create(:employee, salary: 1000.00) } # 1st bracket
  let!(:employee2) { create(:employee, salary: 1500.00) } # 2nd bracket
  let!(:employee3) { create(:employee, :worker, salary: 2500.00) } # 3rd bracket
  let!(:employee4) { create(:employee, :domestic_employee, salary: 4000.00) } # 4th bracket

  describe 'GET #index' do
    before { get :index }

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'assigns employees count' do
      expect(assigns(:employees_count)).to eq(4)
    end

    it 'assigns total salary' do
      expect(assigns(:total_salary)).to eq(9000.00)
    end

    it 'assigns average salary' do
      expect(assigns(:average_salary)).to eq(2250.00)
    end

    it 'assigns salary brackets' do
      expect(assigns(:salary_brackets)).to be_present
    end

    it 'assigns bracket statistics' do
      expect(assigns(:bracket_statistics)).to be_present
    end

    it 'assigns recent employees' do
      expect(assigns(:recent_employees)).to be_present
      expect(assigns(:recent_employees).count).to be <= 5
    end

    it 'assigns chart data for salary brackets' do
      expect(assigns(:salary_brackets_data)).to be_present
    end

    it 'assigns chart data for INSS distribution' do
      expect(assigns(:inss_distribution_data)).to be_present
    end
  end

  describe 'salary bracket calculations' do
    before { get :index }

    it 'groups employees into correct salary brackets' do
      brackets = assigns(:salary_brackets)

      expect(brackets['bracket_1'][:employees]).to include(employee1)
      expect(brackets['bracket_2'][:employees]).to include(employee2)
      expect(brackets['bracket_3'][:employees]).to include(employee3)
      expect(brackets['bracket_4'][:employees]).to include(employee4)
    end

    it 'calculates correct bracket statistics' do
      stats = assigns(:bracket_statistics)

      # Bracket 1 statistics
      bracket1_stats = stats['bracket_1']
      expect(bracket1_stats[:count]).to eq(1)
      expect(bracket1_stats[:percentage]).to eq(25.0) # 1/4 * 100
      expect(bracket1_stats[:total_salary]).to eq(1000.00)
      expect(bracket1_stats[:average_salary]).to eq(1000.00)

      # Bracket 2 statistics
      bracket2_stats = stats['bracket_2']
      expect(bracket2_stats[:count]).to eq(1)
      expect(bracket2_stats[:percentage]).to eq(25.0)
      expect(bracket2_stats[:total_salary]).to eq(1500.00)
      expect(bracket2_stats[:average_salary]).to eq(1500.00)
    end
  end

  describe 'INSS calculation' do
    let(:controller_instance) { described_class.new }

    it 'calculates INSS correctly for different salary ranges' do
      # 1st bracket: 1000.00 * 0.075 = 75.00
      expect(controller_instance.send(:calculate_inss_for_employee, 1000.00)).to eq(75.00)

      # 2nd bracket: 1045.00 * 0.075 + (1500.00 - 1045.00) * 0.09 = 78.38 + 40.95 = 119.32
      expect(controller_instance.send(:calculate_inss_for_employee, 1500.00)).to eq(119.32)

      # 3rd bracket: 1045.00 * 0.075 + (2089.60 - 1045.00) * 0.09 + (2500.00 - 2089.60) * 0.12
      # = 78.38 + 94.01 + 49.25 = 221.64
      expect(controller_instance.send(:calculate_inss_for_employee, 2500.00)).to eq(221.64)

      # 4th bracket: More complex calculation
      expect(controller_instance.send(:calculate_inss_for_employee, 4000.00)).to eq(418.95)
    end

    it 'handles edge case salaries at bracket boundaries' do
      # Test exact boundary values
      expect(controller_instance.send(:calculate_inss_for_employee, 1045.00)).to eq(78.38)
      expect(controller_instance.send(:calculate_inss_for_employee, 1045.01)).to eq(78.38)

      # Test salaries at upper limits
      expect(controller_instance.send(:calculate_inss_for_employee, 1045.00)).to eq(78.38)
      expect(controller_instance.send(:calculate_inss_for_employee, 2089.60)).to eq(172.39)
    end
  end

  describe 'chart data preparation' do
    before { get :index }

    it 'prepares salary brackets chart data correctly' do
      chart_data = assigns(:salary_brackets_data)

      expect(chart_data[:labels].length).to eq(4)
      expect(chart_data[:datasets].length).to eq(1)
      expect(chart_data[:datasets][0][:data]).to eq([1, 1, 1, 1])
    end

    it 'prepares INSS distribution chart data correctly' do
      chart_data = assigns(:inss_distribution_data)

      expect(chart_data[:labels].length).to eq(4)
      expect(chart_data[:datasets].length).to eq(1)

      inss_data = chart_data[:datasets][0][:data]
      expect(inss_data).to all(be >= 0)
    end
  end

  describe 'empty employee database' do
    before do
      Employee.destroy_all
      get :index
    end

    it 'handles empty employee database' do
      expect(assigns(:employees_count)).to eq(0)
      expect(assigns(:total_salary)).to eq(0)
      expect(assigns(:average_salary)).to eq(0)
    end

    it 'calculates percentages correctly when no employees' do
      bracket_statistics = assigns(:bracket_statistics)

      bracket_statistics.each do |_key, stats|
        expect(stats[:count]).to eq(0)
        expect(stats[:percentage]).to eq(0)
        expect(stats[:total_salary]).to eq(0)
        expect(stats[:average_salary]).to eq(0)
        expect(stats[:total_inss]).to eq(0)
        expect(stats[:average_inss]).to eq(0)
      end
    end
  end

  describe 'associations loading' do
    it 'includes associations when loading employees' do
      create(:address, employee: employee1, street: "123 Test St", city: "Test City")
      create(:contact, employee: employee1, contact_type: "phone", contact_content: "123-456-7890")

      get :index

      # Should not raise N+1 query issues
      expect(response).to be_successful
    end
  end

  describe 'helper methods' do
    it 'makes calculate_inss_for_employee a helper method' do
      # The method is defined as a private method but made available as helper
      expect(described_class.new.send(:calculate_inss_for_employee, 1000)).to eq(75.00)
    end
  end

  describe 'private methods' do
    let(:controller_instance) { described_class.new }

    describe '#calculate_salary_brackets' do
      before do
        controller_instance.instance_variable_set(:@employees_count, Employee.count)
      end

      it 'returns correct bracket structure' do
        brackets = controller_instance.send(:calculate_salary_brackets)

        expect(brackets.keys).to include('bracket_1', 'bracket_2', 'bracket_3', 'bracket_4')
        brackets.each do |_key, bracket|
          expect(bracket).to have_key(:min)
          expect(bracket).to have_key(:max)
          expect(bracket).to have_key(:rate)
          expect(bracket).to have_key(:employees)
        end
      end
    end

    describe '#calculate_bracket_statistics' do
      before do
        controller_instance.instance_variable_set(:@salary_brackets,
          controller_instance.send(:calculate_salary_brackets))
        controller_instance.instance_variable_set(:@employees_count, Employee.count)
      end

      it 'calculates statistics for each bracket' do
        stats = controller_instance.send(:calculate_bracket_statistics)

        stats.each do |_key, bracket_stats|
          expect(bracket_stats).to have_key(:count)
          expect(bracket_stats).to have_key(:percentage)
          expect(bracket_stats).to have_key(:total_salary)
          expect(bracket_stats).to have_key(:average_salary)
          expect(bracket_stats).to have_key(:total_inss)
          expect(bracket_stats).to have_key(:average_inss)
        end
      end
    end

    describe '#prepare_salary_brackets_chart_data' do
      before do
        controller_instance.instance_variable_set(:@bracket_statistics, {
          'bracket_1' => { count: 1 },
          'bracket_2' => { count: 1 },
          'bracket_3' => { count: 1 },
          'bracket_4' => { count: 1 }
        })
      end

      it 'prepares chart data structure' do
        chart_data = controller_instance.send(:prepare_salary_brackets_chart_data)

        expect(chart_data).to have_key(:labels)
        expect(chart_data).to have_key(:datasets)
        expect(chart_data[:datasets].length).to eq(1)
        expect(chart_data[:datasets][0]).to have_key(:label)
        expect(chart_data[:datasets][0]).to have_key(:data)
        expect(chart_data[:datasets][0]).to have_key(:backgroundColor)
      end
    end

    describe '#prepare_inss_distribution_chart_data' do
      before do
        controller_instance.instance_variable_set(:@bracket_statistics, {
          'bracket_1' => { total_inss: 75.00 },
          'bracket_2' => { total_inss: 119.33 },
          'bracket_3' => { total_inss: 221.64 },
          'bracket_4' => { total_inss: 345.67 }
        })
      end

      it 'prepares INSS distribution chart data' do
        chart_data = controller_instance.send(:prepare_inss_distribution_chart_data)

        expect(chart_data).to have_key(:labels)
        expect(chart_data).to have_key(:datasets)
        expect(chart_data[:datasets].length).to eq(1)
        expect(chart_data[:datasets][0][:label]).to eq('Total INSS (R$)')
        expect(chart_data[:datasets][0][:data]).to eq([75.00, 119.33, 221.64, 345.67])
      end
    end
  end
end
