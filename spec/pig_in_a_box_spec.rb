require './pig_in_a_box'

RSpec.describe 'hello' do
  def app
    Sinatra::Application
  end

  describe 'POST /api/v1/payments' do
    describe 'with no params' do
      it 'should fail' do
        post '/api/v1/payments', {}, {"HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"}
        expect(last_response.status).to eq 400
      end
    end

    describe 'with correct params' do
      let(:params) { {
          opaqueData: {
            dataDescriptor: "foo",
            dataValue: "bar"
          },
          amount: 75.00,
          customerEmail: 'foo@bar.baz',
          orderDescription: '5 golden rings'
        }
      }

      before do
        expect_any_instance_of(Sinatra::Application).to receive(:process_response).and_return({})
        post '/api/v1/payments', params, {"HTTP_X_REQUESTED_WITH" => "XMLHttpRequest"}
      end

      it 'should succeed' do
        puts last_response.status
        expect(last_response).to be_ok
      end
    end
  end

end
